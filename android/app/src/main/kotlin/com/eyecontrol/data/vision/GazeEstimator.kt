package com.eyecontrol.data.vision

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.google.ai.edge.litert.Accelerator
import com.google.ai.edge.litert.CompiledModel
import com.google.ai.edge.litert.TensorBuffer
import kotlin.math.max

/**
 * L2CS-Gaze360 estimator.
 *
 * Input: [1,3,448,448] NCHW RGB, ImageNet normalized.
 * Outputs: yaw [1,90] and pitch [1,90] softmax probabilities.
 * Angle = sum(p_i * i) * 4 - 180.
 */
class GazeEstimator(context: Context) : AutoCloseable {
    companion object {
        private const val TAG = "GazeEstimator"
        private const val MODEL_PATH = "models/gaze_fp16.tflite"
        private const val INPUT_SIZE = 448
        private const val BINS = 90
        private val MEAN = floatArrayOf(0.485f, 0.456f, 0.406f)
        private val STD = floatArrayOf(0.229f, 0.224f, 0.225f)

        internal fun decodeAngle(probs: FloatArray): Float {
            if (probs.size != BINS) return 0f
            var expectation = 0f
            for (i in probs.indices) expectation += probs[i] * i
            return expectation * 4f - 180f
        }
    }

    private val model: CompiledModel
    private val inputBuffer: TensorBuffer
    private val outputBuffers: Array<TensorBuffer>
    private val accelerator: Accelerator

    init {
        val loaded = try {
            Log.d(TAG, "Loading L2CS-Net with GPU from $MODEL_PATH")
            Triple(
                CompiledModel.create(
                    context.assets,
                    MODEL_PATH,
                    CompiledModel.Options(Accelerator.GPU),
                    null,
                ),
                Accelerator.GPU,
                "GPU",
            )
        } catch (gpuError: Exception) {
            Log.w(TAG, "GPU initialization failed; falling back to CPU: " + gpuError.message, gpuError)
            Triple(
                CompiledModel.create(
                    context.assets,
                    MODEL_PATH,
                    CompiledModel.Options(Accelerator.CPU),
                    null,
                ),
                Accelerator.CPU,
                "CPU",
            )
        }

        model = loaded.first
        accelerator = loaded.second
        val inputs = model.createInputBuffers()
        val outputs = model.createOutputBuffers()
        require(inputs.isNotEmpty()) { "L2CS model exposes no input tensors" }
        require(outputs.size >= 2) { "L2CS model must expose yaw and pitch outputs" }
        inputBuffer = inputs[0]
        outputBuffers = outputs

        Log.d(TAG, "L2CS-Net loaded successfully on " + loaded.third + "; outputs=" + outputs.size)
    }

    fun estimate(faceBitmap: Bitmap): Pair<Float, Float>? {
        if (faceBitmap.isRecycled || faceBitmap.width <= 0 || faceBitmap.height <= 0) return null
        return try {
            val resized = Bitmap.createScaledBitmap(faceBitmap, INPUT_SIZE, INPUT_SIZE, true)
            val input = bitmapToChw(resized)
            if (resized !== faceBitmap) resized.recycle()

            inputBuffer.writeFloat(input)
            model.run(arrayOf(inputBuffer), outputBuffers)

            val yaw = decodeAngle(outputBuffers[0].readFloat())
            val pitch = decodeAngle(outputBuffers[1].readFloat())

            Log.d(TAG, "Gaze accelerator=" + accelerator + " yaw=" + yaw + " pitch=" + pitch)
            Pair(yaw, pitch)
        } catch (error: Exception) {
            Log.e(TAG, "Gaze estimation failed; MediaPipe fallback remains active: " + error.message, error)
            null
        }
    }

    private fun bitmapToChw(bitmap: Bitmap): FloatArray {
        val pixels = IntArray(bitmap.width * bitmap.height)
        bitmap.getPixels(pixels, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)
        val planeSize = bitmap.width * bitmap.height
        val chw = FloatArray(planeSize * 3)

        for (i in pixels.indices) {
            val pixel = pixels[i]
            val r = ((pixel ushr 16) and 0xFF) / 255f
            val g = ((pixel ushr 8) and 0xFF) / 255f
            val b = (pixel and 0xFF) / 255f
            chw[i] = (r - MEAN[0]) / max(STD[0], 1e-6f)
            chw[planeSize + i] = (g - MEAN[1]) / max(STD[1], 1e-6f)
            chw[planeSize * 2 + i] = (b - MEAN[2]) / max(STD[2], 1e-6f)
        }
        return chw
    }

    override fun close() {
        try {
            model.close()
            Log.d(TAG, "L2CS-Net closed")
        } catch (error: Exception) {
            Log.e(TAG, "Error closing L2CS-Net: " + error.message, error)
        }
    }
}
