package com.eyecontrol.domain.usecase

import com.eyecontrol.domain.model.ScreenPoint
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class DwellControllerTest {
    private fun point(x: Float = 100f, y: Float = 100f, blink: Boolean = false) =
        ScreenPoint(x, y, 1f, blink, System.nanoTime())

    @Test
    fun firstPoint_startsProgress() {
        val controller = DwellController(durationMs = 300L, radiusPx = 50f) { _, _ -> }
        val state = controller.update(point())
        assertEquals(0f, state.progress, 0.001f)
        assertEquals(false, state.fired)
    }

    @Test
    fun movement_cancelsAndStartsNewAnchor() {
        val controller = DwellController(durationMs = 300L, radiusPx = 20f) { _, _ -> }
        controller.update(point())
        val state = controller.update(point(x = 200f))
        assertTrue(state.cancelled)
        assertEquals(0f, state.progress, 0.001f)
    }

    @Test
    fun blink_freezesInsteadOfResetting() {
        val controller = DwellController(durationMs = 300L, radiusPx = 50f) { _, _ -> }
        controller.update(point())
        Thread.sleep(40)
        val before = controller.update(point(blink = true))
        Thread.sleep(40)
        val after = controller.update(point())
        assertTrue(after.progress >= before.progress)
        assertTrue(after.progress < 1f)
    }

    @Test
    fun dwell_firesOnce() {
        var fired = 0
        val controller = DwellController(durationMs = 300L, radiusPx = 50f) { _, _ -> fired++ }
        controller.update(point())
        Thread.sleep(320)
        val state = controller.update(point())
        assertTrue(state.fired)
        assertEquals(1, fired)
    }

    @Test
    fun cooldown_preventsImmediateSecondFire() {
        var fired = 0
        val controller = DwellController(durationMs = 300L, radiusPx = 50f) { _, _ -> fired++ }
        controller.update(point())
        Thread.sleep(320)
        controller.update(point())
        Thread.sleep(20)
        controller.update(point())
        assertEquals(1, fired)
    }

    @Test
    fun reset_clearsProgress() {
        val controller = DwellController(durationMs = 300L, radiusPx = 50f) { _, _ -> }
        controller.update(point())
        controller.reset()
        assertEquals(0f, controller.update(point(blink = true)).progress, 0.001f)
    }
}
