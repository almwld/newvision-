package com.eyecontrol.domain.usecase

import com.eyecontrol.data.calibration.CalibrationManager
import com.eyecontrol.data.filter.GazeSmoother
import com.eyecontrol.domain.model.GazeSample
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

class ProcessGazeUseCaseTest {
    private fun useCase(): ProcessGazeUseCase = ProcessGazeUseCase(
        smoother = GazeSmoother(),
        calibrationManager = CalibrationManager(null),
        screenWidth = 1000,
        screenHeight = 1000,
    )

    private fun sample(
        x: Float = 0.5f,
        y: Float = 0.5f,
        open: Boolean = true,
        confidence: Float = 0.9f,
        timestampNs: Long = 1_000_000L,
    ) = GazeSample(
        rawX = x,
        rawY = y,
        leftIrisX = x,
        leftIrisY = y,
        rightIrisX = x,
        rightIrisY = y,
        confidence = confidence,
        pupilDiameter = 0.1f,
        eyeOpen = open,
        timestampNs = timestampNs,
    )

    @Test
    fun openEye_producesScreenPoint() {
        val point = useCase().process(sample())
        assertNotNull(point)
        assertEquals(500f, point!!.xPx, 0.01f)
        assertEquals(500f, point.yPx, 0.01f)
    }

    @Test
    fun closedEye_holdsLastPoint() {
        val useCase = useCase()
        useCase.process(sample())
        val point = useCase.process(sample(open = false, timestampNs = 2_000_000L))
        assertNotNull(point)
        assertEquals(500f, point!!.xPx, 0.01f)
        assertEquals(500f, point.yPx, 0.01f)
        assertEquals(true, point.isBlinking)
    }

    @Test
    fun firstClosedEye_returnsNull() {
        assertNull(useCase().process(sample(open = false)))
    }

    @Test
    fun lowConfidence_stillProducesPoint() {
        assertNotNull(useCase().process(sample(confidence = 0.05f)))
    }

    @Test
    fun reset_clearsHeldPoint() {
        val useCase = useCase()
        useCase.process(sample())
        useCase.reset()
        assertNull(useCase.process(sample(open = false, timestampNs = 2_000_000L)))
    }
}
