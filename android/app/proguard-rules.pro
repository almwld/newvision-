# NewVision release R8 rules.
# Keep framework code that is accessed through reflection/native bindings.

-keep class com.google.mediapipe.** { *; }
-keep class com.google.ai.edge.litert.** { *; }
-keep class org.tensorflow.** { *; }

-keep class com.eyecontrol.MainActivity { *; }
-keep class com.eyecontrol.EyeControlApplication { *; }
-keep class com.eyecontrol.data.vision.** { *; }
-keep class com.eyecontrol.data.camera.** { *; }
-keep class com.eyecontrol.domain.model.** { *; }

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keepattributes *Annotation*, InnerClasses, Signature, SourceFile, LineNumberTable
-keep class kotlin.Metadata { *; }

-dontwarn com.google.mediapipe.**
-dontwarn com.google.ai.edge.litert.**
-dontwarn org.tensorflow.**
-dontwarn javax.annotation.processing.**
-dontwarn javax.lang.model.**

# Safe release optimizations; source/features are not removed from the repository.
-allowaccessmodification
-optimizations !code/simplification/arithmetic
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
