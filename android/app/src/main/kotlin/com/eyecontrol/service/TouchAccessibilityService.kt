package com.eyecontrol.service
import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import java.util.concurrent.atomic.AtomicReference
class TouchAccessibilityService : AccessibilityService() {
 override fun onServiceConnected(){ instance.set(this); super.onServiceConnected() }
 override fun onDestroy(){ instance.compareAndSet(this,null); super.onDestroy() }
 override fun onAccessibilityEvent(event: AccessibilityEvent?)=Unit
 override fun onInterrupt()=Unit
 private fun dispatchSwipe(sx:Float,sy:Float,ex:Float,ey:Float):Boolean{
  if(Build.VERSION.SDK_INT<Build.VERSION_CODES.N)return false
  val path=Path().apply{moveTo(sx,sy);lineTo(ex,ey)}
  return dispatchGesture(GestureDescription.Builder().addStroke(GestureDescription.StrokeDescription(path,0L,300L)).build(),null,null)
 }
 private fun tap(x:Float,y:Float):Boolean{
  if(Build.VERSION.SDK_INT<Build.VERSION_CODES.N)return false
  val path=Path().apply{moveTo(x,y)}
  return dispatchGesture(GestureDescription.Builder().addStroke(GestureDescription.StrokeDescription(path,0L,80L)).build(),null,null)
 }
 fun scrollUp():Boolean{val w=resources.displayMetrics.widthPixels.toFloat();val h=resources.displayMetrics.heightPixels.toFloat();return dispatchSwipe(w*.5f,h*.30f,w*.5f,h*.70f)}
 fun scrollDown():Boolean{val w=resources.displayMetrics.widthPixels.toFloat();val h=resources.displayMetrics.heightPixels.toFloat();return dispatchSwipe(w*.5f,h*.70f,w*.5f,h*.30f)}
 fun scrollLeft():Boolean{val w=resources.displayMetrics.widthPixels.toFloat();val h=resources.displayMetrics.heightPixels.toFloat();return dispatchSwipe(w*.30f,h*.5f,w*.70f,h*.5f)}
 fun scrollRight():Boolean{val w=resources.displayMetrics.widthPixels.toFloat();val h=resources.displayMetrics.heightPixels.toFloat();return dispatchSwipe(w*.70f,h*.5f,w*.30f,h*.5f)}
 companion object{private val instance=AtomicReference<TouchAccessibilityService?>();fun getInstance():TouchAccessibilityService?=instance.get();fun performTap(x:Float,y:Float):Boolean=instance.get()?.tap(x,y)==true}
}