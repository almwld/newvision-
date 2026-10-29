package com.eyecontrol.data.vision

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import org.tensorflow.lite.DataType
import org.tensorflow.lite.Interpreter
import kotlin.math.exp
import kotlin.math.max

/**
 * Optional L2CS angle estimator.
 *
 * Face/iris tracking must remain usable when the separately supplied L2CS model
 * is not bundled. In that case [infer] returns null and the gaze pipeline falls
 * back to the normalized iris features instead of failing camera initialization.
 */
class L2csInferenceEngine(context: Context) : AutoCloseable {
    companion object {
        const val MODEL_ASSET = "flutter_assets/assets/models/gaze_fp16.tflite"
        const val INPUT_SIZE = 448
        const val BINS = 90
        private const val TAG = "L2csInferenceEngine"
        private const val BIN_WIDTH = 4f
        private const val MIN_ANGLE = -180f
        private const val FACE_MARGIN = 0.18f
        private val MEAN = floatArrayOf(0.485f, 0.456f, 0.406f)
        private val STD = floatArrayOf(0.229f, 0.224f, 0.225f)
    }

    data class Result(val yawDegrees: Float, val pitchDegrees: Float, val confidence: Float)

    private val interpreter: Interpreter? = loadInterpreter(context)

    private fun loadInterpreter(context: Context): Interpreter? {
        val modelFile = File(context.cacheDir, "gaze_fp16.tflite")
        return try {
            if (!modelFile.exists() || modelFile.length() == 0L) {
                // Do not leave an empty/partial cache file if the optional asset is absent.
                modelFile.delete()
                try {
                    context.assets.open(MODEL_ASSET).use { input ->
                        FileOutputStream(modelFile).use { output -> input.copyTo(output) }
                    }
                } catch (error: Exception) {
                    modelFile.delete()
                    Log.w(TAG, "L2CS model is not bundled; using iris-feature tracking.", error)
                    return null
                }
            }

            val options = Interpreter.Options().apply { setNumThreads(2) }
            val loaded = Interpreter(modelFile, options)
            try {
                loaded.allocateTensors()
                validateContract(loaded)
                loaded
            } catch (error: Exception) {
                loaded.close()
                throw error
            }
        } catch (error: Exception) {
            Log.e(TAG, "L2CS model could not be initialized; using iris-feature tracking.", error)
            null
        }
    }

    private fun validateContract(model: Interpreter) {
        val input = model.getInputTensor(0)
        require(input.dataType() == DataType.FLOAT32) { "L2CS input must be FLOAT32" }
        require(input.shape().contentEquals(intArrayOf(1, 3, INPUT_SIZE, INPUT_SIZE))) {
            "Unexpected L2CS input shape: ${input.shape().contentToString()}"
        }
        require(model.outputTensorCount >= 2) { "L2CS requires yaw and pitch outputs" }
        for (index in 0..1) {
            val tensor = model.getOutputTensor(index)
            require(tensor.dataType() == DataType.FLOAT32) { "L2CS output $index must be FLOAT32" }
            val shape = tensor.shape()
            require(shape.contentEquals(intArrayOf(1, BINS)) || shape.contentEquals(intArrayOf(BINS))) {
                "Unexpected L2CS output shape: ${shape.contentToString()}"
            }
        }
    }

    fun infer(
        frame: Bitmap,
        left: Float,
        top: Float,
        right: Float,
        bottom: Float,
    ): Result? {
        val model = interpreter ?: return null
        val roi = cropFace(frame, left, top, right, bottom) ?: return null
        try {
            val input = ByteBuffer.allocateDirect(4 * 3 * INPUT_SIZE * INPUT_SIZE)
                .order(ByteOrder.nativeOrder())
            fillNchw(input, roi)
            input.rewind()

            val yawOutput = createOutput(model.getOutputTensor(0).shape())
            val pitchOutput = createOutput(model.getOutputTensor(1).shape())
            model.runForMultipleInputsOutputs(arrayOf(input), mapOf(0 to yawOutput, 1 to pitchOutput))
            val yaw = decode(readOutput(yawOutput))
            val pitch = decode(readOutput(pitchOutput))
            return Result(
                yawDegrees = yaw.first,
                pitchDegrees = pitch.first,
                confidence = ((yaw.second + pitch.second) * 0.5f).coerceIn(0f, 1f),
            )
        } finally {
            roi.recycle()
        }
    }

    private fun createOutput(shape: IntArray): Any =
        if (shape.contentEquals(intArrayOf(1, BINS))) {
            Array(1) { FloatArray(BINS) }
        } else {
            FloatArray(BINS)
        }

    private fun readOutput(output: Any): FloatArray = when (output) {
        is Array<*> -> (output.firstOrNull() as? FloatArray)
            ?: error("L2CS returned an invalid batched output")
        is FloatArray -> output
        else -> error("Unsupported L2CS output container: ${output::class.java.name}")
    }

    private fun cropFace(
        source: Bitmap,
        left: Float,
        top: Float,
        right: Float,
        bottom: Float,
    ): Bitmap? {
        if (source.isRecycled || source.width <= 0 || source.height <= 0) return null
        if (listOf(left, top, right, bottom).any { !it.isFinite() }) return null

        val boundedLeft = left.coerceIn(0f, (source.width - 1).toFloat())
        val boundedTop = top.coerceIn(0f, (source.height - 1).toFloat())
        val boundedRight = right.coerceIn(boundedLeft + 1f, source.width.toFloat())
        val boundedBottom = bottom.coerceIn(boundedTop + 1f, source.height.toFloat())
        val faceWidth = (boundedRight - boundedLeft).coerceAtLeast(1f)
        val faceHeight = (boundedBottom - boundedTop).coerceAtLeast(1f)
        val requestedSize = (max(faceWidth, faceHeight) * (1f + FACE_MARGIN * 2f))
            .toInt().coerceAtLeast(1)
        val centerX = (boundedLeft + boundedRight) * 0.5f
        val centerY = (boundedTop + boundedBottom) * 0.5f
        val size = requestedSize.coerceAtMost(minOf(source.width, source.height))
        val x = (centerX - size * 0.5f).toInt().coerceIn(0, source.width - size)
        val y = (centerY - size * 0.5f).toInt().coerceIn(0, source.height - size)

        val crop = Bitmap.createBitmap(source, x, y, size, size)
        return try {
            Bitmap.createScaledBitmap(crop, INPUT_SIZE, INPUT_SIZE, true)
                .also { scaled -> if (scaled !== crop) crop.recycle() }
        } catch (error: Exception) {
            crop.recycle()
            throw error
        }
    }

    private fun fillNchw(buffer: ByteBuffer, bitmap: Bitmap) {
        val pixels = IntArray(INPUT_SIZE * INPUT_SIZE)
        bitmap.getPixels(pixels, 0, INPUT_SIZE, 0, 0, INPUT_SIZE, INPUT_SIZE)
        for (channel in 0..2) {
            for (pixel in pixels) {
                val raw = when (channel) {
                    0 -> (pixel shr 16) and 0xFF
                    1 -> (pixel shr 8) and 0xFF
                    else -> pixel and 0xFF
                }
                buffer.putFloat((raw / 255f - MEAN[channel]) / STD[channel])
            }
        }
    }

    private fun decode(values: FloatArray): Pair<Float, Float> {
        require(values.size == BINS && values.all { it.isFinite() }) {
            "L2CS output must contain $BINS finite values"
        }
        val total = values.sum()
        val probabilities = if (
            values.all { it >= 0f && it <= 1f } && total.isFinite() && total in 0.98f..1.02f
        ) {
            values
        } else {
            val maxLogit = values.maxOrNull() ?: 0f
            val exps = FloatArray(BINS) { exp(values[it] - maxLogit) }
            val sum = exps.sum().coerceAtLeast(1e-12f)
            FloatArray(BINS) { exps[it] / sum }
        }
        var angle = 0f
        var peak = 0f
        for (i in 0 until BINS) {
            angle += probabilities[i] * (MIN_ANGLE + i * BIN_WIDTH)
            peak = max(peak, probabilities[i])
        }
        return angle.coerceIn(-180f, 180f) to peak.coerceIn(0f, 1f)
    }

    override fun close() {
        interpreter?.close()
    }
}
