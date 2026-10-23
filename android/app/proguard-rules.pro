# Retain annotation information (needed for some SDK reflection)
-keepattributes *Annotation*

# Suppress warnings for the missing ProGuard annotations
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Keep all Razorpay SDK classes and their members
-dontwarn com.razorpay.**
-keep class com.razorpay.** { *; }

# Disable specific optimizations that might inline methods used in Razorpay's code
-optimizations !method/inlining/

# Optionally, ensure that any onPayment* methods are retained (if your integration relies on them)
-keepclasseswithmembers class * {
  public void onPayment*(...);
}
