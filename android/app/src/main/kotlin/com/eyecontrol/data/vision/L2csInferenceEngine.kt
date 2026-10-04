package com.eyecontrol.data.vision

import android.content.Context
import android.graphics.Bitmap
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.exp
import kotlin.math.max

class L2csInferenceEngine(context: Context) : AutoCloseable {
    companion object {
        const val MODEL_ASSET = "flutter_assets/assets/models/gaze_fp16.tflite"
        const val INPUT_SIZE = 448
        const val BINS = 90
        private const val BIN_WIDTH = 4f
        private const val MIN_ANGLE = -180f
        private const val FACE_MARGIN = 0.18f
        private val MEAN = floatArrayOf(0.485f, 0.456f, 0.406f)
        private val STD = floatArrayOf(0.229f, 0.224f, 0.225f)
    }

    data class Result(val yawDegrees: Float, val pitchDegrees: Float, val confidence: Float)

    private val interpreter: org.tensorflow.lite.Interpreter

    init {
        val modelFile = File(context.cacheDir, "gaze_fp16.tflite")
        if (!modelFile.exists() || modelFile.length() == 0L) {
            context.assets.open(MODEL_ASSET).use { input ->
                FileOutputStream(modelFile).use { output -> input.copyTo(output) }
            }
        }
        val options = org.tensorflow.lite.Interpreter.Options().apply { setNumThreads(2) }
        interpreter = org.tensorflow.lite.Interpreter(modelFile, options)
        interpreter.allocateTensors()
        validateContract()
    }

    private fun validateContract() {
        val input = interpreter.getInputTensor(0)
        require(input.dataType() == org.tensorflow.lite.DataType.FLOAT32) { "L2CS input must be FLOAT32" }
        require(input.shape().contentEquals(intArrayOf(1, 3, INPUT_SIZE, INPUT_SIZE))) {
            "Unexpected L2CS input shape: ${input.shape().contentToString()}"
        }
        require(interpreter.outputTensorCount >= 2) { "L2CS requires yaw and pitch outputs" }
        require(interpreter.getOutputTensor(0).shape().contentEquals(intArrayOf(1, BINS)) ||
            interpreter.getOutputTensor(0).shape().contentEquals(intArrayOf(BINS))) {
            "Unexpected yaw output shape: ${interpreter.getOutputTensor(0).shape().contentToString()}"
        }
        require(interpreter.getOutputTensor(1).shape().contentEquals(intArrayOf(1, BINS)) ||
            interpreter.getOutputTensor(1).shape().contentEquals(intArrayOf(BINS))) {
            "Unexpected pitch output shape: ${interpreter.getOutputTensor(1).shape().contentToString()}"
        }
    }

    fun infer(frame: Bitmap, left: Float, top: Float, right: Float, bottom: Float): Result {
        val roi = cropFace(frame, left, top, right, bottom)
        val input = ByteBuffer.allocateDirect(4 * 3 * INPUT_SIZE * INPUT_SIZE).order(ByteOrder.nativeOrder())
        fillNchw(input, roi)
        input.rewind()
        val yaw = Array(1) { FloatArray(BINS) }
        val pitch = Array(1) { FloatArray(BINS) }
        interpreter.runForMultipleInputsOutputs(arrayOf(input), mapOf(0 to yaw, 1 to pitch))
        val y = decode(yaw[0])
        val p = decode(pitch[0])
        roi.recycle()
        return Result(y.first, p.first, ((y.second + p.second) * 0.5f).coerceIn(0f, 1f))
    }

    private fun cropFace(source: Bitmap, left: Float, top: Float, right: Float, bottom: Float): Bitmap {
        val w = (right - left).coerceAtLeast(1f)
        val h = (bottom - top).coerceAtLeast(1f)
        val size = max(w, h) * (1f + FACE_MARGIN * 2f)
        val cx = (left + right) * 0.5f
        val cy = (top + bottom) * 0.5f
        val x = (cx - size * 0.5f).toInt().coerceIn(0, (source.width - 1).coerceAtLeast(0))
        val y = (cy - size * 0.5f).toInt().coerceIn(0, (source.height - 1).coerceAtLeast(0))
        val cropSize = size.toInt().coerceAtLeast(1).coerceAtMost(minOf(source.width - x, source.height - y))
        val crop = Bitmap.createBitmap(source, x, y, cropSize, cropSize)
        return Bitmap.createScaledBitmap(crop, INPUT_SIZE, INPUT_SIZE, true).also { if (it !== crop) crop.recycle() }
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
        val probabilities = if (values.all { it >= 0f && it <= 1f } && values.sum() in 0.98f..1.02f) {
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

    override fun close() { interpreter.close() }
}
