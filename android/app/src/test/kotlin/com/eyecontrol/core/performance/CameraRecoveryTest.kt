package com.eyecontrol.core.performance
import org.junit.Assert.assertEquals
import org.junit.Test
class CameraRecoveryTest{@Test fun retriesBoundedly(){var n=0;val r=CameraRecovery(3,0);assertEquals(7,r.run{n++;if(n<3)throw IllegalStateException("x") else 7})}}