package com.eyecontrol.data.filter

import org.junit.Assert.assertEquals
import org.junit.Test

class OneEuroFilterTest {
    @Test
    fun firstSample_isReturnedDirectly() {
        val filter = OneEuroFilter()
        assertEquals(1f, filter.filter(1f, 0L), 0.0001f)
    }
}
