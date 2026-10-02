package com.eyecontrol.data.settings

import com.eyecontrol.domain.model.ScreenPoint
import org.junit.Assert.*
import org.junit.Test

class GazeZoneTest {
    private fun point(x: Float, y: Float, blink: Boolean = false) = ScreenPoint(
        xPx = x, yPx = y, confidence = 1f, isBlinking = blink, timestampNs = 1L,
    )

    @Test fun disabled_returnsNull() {
        val detector = GazeZoneDetector(1000, 2000) { GazeZoneSettings() }
        assertNull(detector.detect(point(10f, 10f)))
    }

    @Test fun enabled_respectsEachToggle() {
        val detector = GazeZoneDetector(1000, 2000) {
            GazeZoneSettings(enabled = true, scrollUpEnabled = true)
        }
        assertEquals(GazeZone.TOP, detector.detect(point(500f, 100f)))
        assertNull(detector.detect(point(500f, 1900f)))
    }

    @Test fun blink_neverActivatesZone() {
        val detector = GazeZoneDetector(1000, 2000) {
            GazeZoneSettings(enabled = true, scrollUpEnabled = true)
        }
        assertNull(detector.detect(point(500f, 100f, blink = true)))
    }

    @Test fun tracker_requiresStableZone() {
        var now = 0L
        val tracker = ZoneActivationTracker(300, 250) { now }
        assertTrue(tracker.update(GazeZone.TOP) is ZoneActivationResult.Active)
        now = 299
        assertTrue(tracker.update(GazeZone.TOP) is ZoneActivationResult.Active)
        now = 300
        assertEquals(ZoneActivationResult.Activated, tracker.update(GazeZone.TOP))
        assertEquals(ZoneActivationResult.None, tracker.update(GazeZone.TOP))
        now = 550
        assertTrue(tracker.update(GazeZone.TOP) is ZoneActivationResult.Active)
    }

    @Test fun tracker_switchingZone_restartsActivation() {
        var now = 0L
        val tracker = ZoneActivationTracker(300, 0) { now }
        tracker.update(GazeZone.LEFT)
        now = 250
        assertTrue(tracker.update(GazeZone.RIGHT) is ZoneActivationResult.Active)
        now = 549
        assertTrue(tracker.update(GazeZone.RIGHT) is ZoneActivationResult.Active)
        now = 550
        assertEquals(ZoneActivationResult.Activated, tracker.update(GazeZone.RIGHT))
    }
}
