import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

class SecuritySettingsView extends StatelessWidget {
  SecuritySettingsView({Key? key}) : super(key: key);

  final RxBool twoFactorEnabled = false.obs;
  final RxBool biometricEnabled = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(
          'Security Settings',
          style: Latofont.copyWith(
            color: context.themeTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.colors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.themeTextColor, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.themePrimaryColor,
                      context.themePrimaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.themePrimaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 64,
                      color: context.colors.onPrimary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Account is Secure',
                      style: Latofont.copyWith(
                        color: context.colors.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Last login was 2 minutes ago from this device',
                      textAlign: TextAlign.center,
                      style: Latofont.copyWith(
                        color: context.colors.onPrimary.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Security Preferences Section
              Text(
                'PREFERENCES',
                style: Latofont.copyWith(
                  color: context.themeSecondrytext,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              
              // Two-Factor Auth Switch Tile
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                color: context.colors.surface,
                child: Obx(() => SwitchListTile(
                  value: twoFactorEnabled.value,
                  onChanged: (val) {
                    twoFactorEnabled.value = val;
                    Get.snackbar(
                      "Security Update",
                      val ? "Two-Factor Authentication Enabled" : "Two-Factor Authentication Disabled",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                    );
                  },
                  secondary: CircleAvatar(
                    backgroundColor: context.themePrimaryColor.withOpacity(0.1),
                    child: Icon(Icons.phonelink_ring_outlined, color: context.themePrimaryColor),
                  ),
                  title: Text(
                    'Two-Factor Authentication',
                    style: Latofont.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Secure your account with an SMS OTP code.',
                    style: Latofont.copyWith(fontSize: 12, color: context.themeSecondrytext),
                  ),
                  activeColor: context.themePrimaryColor,
                )),
              ),
              
              // Biometric Login Switch Tile
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                color: context.colors.surface,
                child: Obx(() => SwitchListTile(
                  value: biometricEnabled.value,
                  onChanged: (val) {
                    biometricEnabled.value = val;
                    Get.snackbar(
                      "Security Update",
                      val ? "Biometric Verification Enabled" : "Biometric Verification Disabled",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                    );
                  },
                  secondary: CircleAvatar(
                    backgroundColor: context.themePrimaryColor.withOpacity(0.1),
                    child: Icon(Icons.fingerprint_outlined, color: context.themePrimaryColor),
                  ),
                  title: Text(
                    'Biometric Login',
                    style: Latofont.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Use FaceID or Fingerprint to log in quickly.',
                    style: Latofont.copyWith(fontSize: 12, color: context.themeSecondrytext),
                  ),
                  activeColor: context.themePrimaryColor,
                )),
              ),

              const SizedBox(height: 24),

              // General Settings Section
              Text(
                'ACCOUNT ACTIONS',
                style: Latofont.copyWith(
                  color: context.themeSecondrytext,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              // Change Password Tile
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                color: context.colors.surface,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.themePrimaryColor.withOpacity(0.1),
                    child: Icon(Icons.lock_reset_outlined, color: context.themePrimaryColor),
                  ),
                  title: Text(
                    'Change Password',
                    style: Latofont.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.snackbar(
                      "Password Action",
                      "Password reset email sent successfully",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                    );
                  },
                ),
              ),

              // Active Devices Tile
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                color: context.colors.surface,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.themePrimaryColor.withOpacity(0.1),
                    child: Icon(Icons.devices_outlined, color: context.themePrimaryColor),
                  ),
                  title: Text(
                    'Manage Active Devices',
                    style: Latofont.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    'View and logout of devices logged into your account.',
                    style: Latofont.copyWith(fontSize: 12, color: context.themeSecondrytext),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show dialog or sheet with active devices list
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Devices',
                              style: Latofont.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: Icon(Icons.phone_android, color: context.themePrimaryColor),
                              title: const Text('iPhone 14 Pro Max (Current Device)'),
                              subtitle: const Text('New York, USA • Active now'),
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(Icons.laptop_mac, color: context.themeSecondrytext),
                              title: const Text('MacBook Pro 16"'),
                              subtitle: const Text('London, UK • 2 hours ago'),
                              trailing: TextButton(
                                onPressed: () {
                                  Get.back();
                                  Get.snackbar("Device Logged Out", "MacBook Pro session terminated.");
                                },
                                child: Text('Logout', style: TextStyle(color: context.themeRedColor)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              
              // Device Security Alerts log (Dynamic listing relevant to notification alert)
              Text(
                'SECURITY ALERTS LOG',
                style: Latofont.copyWith(
                  color: context.themeSecondrytext,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 2,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final isNew = index == 0;
                    return ListTile(
                      leading: Icon(
                        isNew ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                        color: isNew ? Colors.amber : Colors.green,
                      ),
                      title: Text(
                        isNew ? 'New Login Detected' : 'Password Changed',
                        style: Latofont.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        isNew 
                            ? 'A new device logged in from a new IP address.' 
                            : 'Your account password was updated successfully.',
                        style: Latofont.copyWith(fontSize: 12, color: context.themeSecondrytext),
                      ),
                      trailing: Text(
                        isNew ? 'Just now' : 'Yesterday',
                        style: Latofont.copyWith(fontSize: 11, color: context.themeSecondrytext),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
