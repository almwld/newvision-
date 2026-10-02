-keep class com.google.mediapipe.** { *; }
-keep class com.eyecontrol.** { *; }

# MediaPipe profiling/template proto references are optional at runtime.
-dontwarn com.google.mediapipe.proto.**

# Java annotation-processing APIs are compile-time only and are not needed at runtime.
-dontwarn javax.annotation.processing.**
-dontwarn javax.lang.model.**
