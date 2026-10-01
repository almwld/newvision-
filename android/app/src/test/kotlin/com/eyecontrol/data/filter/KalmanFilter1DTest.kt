package com.eyecontrol.data.filter

import org.junit.Assert.assertEquals
import org.junit.Test

class KalmanFilter1DTest {
    @Test
    fun firstMeasurement_isReturnedDirectly() {
        val filter = KalmanFilter1D()
        assertEquals(0.5f, filter.update(0.5f), 0.0001f)
    }
}
