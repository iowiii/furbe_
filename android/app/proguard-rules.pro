# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}