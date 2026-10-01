package com.eyecontrol.data.repository

import com.eyecontrol.data.calibration.CalibrationManager
import com.eyecontrol.domain.model.GazeSample
import org.junit.Assert.assertEquals
import org.junit.Test

class NativeGazeRepositoryTest {
    private fun sample(timestampNs: Long, rawX: Float) = GazeSample(
        rawX = rawX, rawY = 0.5f,
        leftIrisX = rawX, leftIrisY = 0.5f,
        rightIrisX = rawX, rightIrisY = 0.5f,
        confidence = 1f, pupilDiameter = 3f,
        eyeOpen = true, timestampNs = timestampNs,
    )

    @Test
    fun lateSample_doesNotOverwriteLatestState() {
        val repository = NativeGazeRepository(CalibrationManager(null), 1000, 1000)
        repository.publish(sample(2_000L, 0.8f))
        repository.publish(sample(1_000L, 0.2f))
        assertEquals(2_000L, repository.latest.value?.timestampNs)
        assertEquals(0.8f, repository.latest.value?.rawX)
        assertEquals(2_000L, repository.latestScreenPoint().value?.timestampNs)
    }

    @Test
    fun reset_allowsNewTimestampSequence() {
        val repository = NativeGazeRepository(CalibrationManager(null), 1000, 1000)
        repository.publish(sample(2_000L, 0.8f))
        repository.reset()
        repository.publish(sample(1_000L, 0.2f))
        assertEquals(1_000L, repository.latest.value?.timestampNs)
    }
}
