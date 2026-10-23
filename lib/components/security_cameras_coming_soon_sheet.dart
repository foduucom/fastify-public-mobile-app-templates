import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/support_call_sheet.dart';
import 'package:zouhi/constants/theme_ext.dart';

/// Shows an informational modal bottom sheet mirroring the parent website's
/// "Security Cameras - Coming Soon" section without any outsmarting or mock forms.
void showSecurityCamerasComingSoonSheet(BuildContext context) {
  Get.bottomSheet(
    const SecurityCamerasComingSoonSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class SecurityCamerasComingSoonSheet extends StatelessWidget {
  const SecurityCamerasComingSoonSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const poppins = 'Poppins';
    final primaryColor = context.themePrimaryColor;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: context.themeWhiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Center drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Top Header: Icon + Badge + Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.videocam_rounded,
                      size: 32,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'COMING SOON',
                            style: TextStyle(
                              fontFamily: poppins,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Security & Surveillance Cameras',
                          style: TextStyle(
                            fontFamily: poppins,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: context.themeTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    splashRadius: 20,
                    color: context.themeSecondrytext,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Informational copy (mirrors website status)
              Text(
                'Our upcoming commercial lineup features NDAA-compliant IP cameras, PoE NVRs, and AI smart surveillance engineered for campus and enterprise networks.',
                style: TextStyle(
                  fontFamily: poppins,
                  fontSize: 13,
                  height: 1.45,
                  color: context.themeSecondrytext,
                ),
              ),

              const SizedBox(height: 20),

              // Section 1: Explore Compatible Infrastructure (Existing Website Section)
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.SOLUTIONS);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.themeBorderColor.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.hub_outlined,
                          color: Color(0xFF0284C7),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Compatible Infrastructure',
                              style: TextStyle(
                                fontFamily: poppins,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.themeTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'PoE switches, bandwidth backbones & racks',
                              style: TextStyle(
                                fontFamily: poppins,
                                fontSize: 11.5,
                                color: context.themeSecondrytext,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: context.themeSecondrytext,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Section 2: Contact Specialist (Existing Support / Phone Channel)
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Get.back();
                  handleSupportCall(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.themeBorderColor.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Color(0xFF10B981),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Speak with a Solutions Specialist',
                              style: TextStyle(
                                fontFamily: poppins,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.themeTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Plan your surveillance architecture early',
                              style: TextStyle(
                                fontFamily: poppins,
                                fontSize: 11.5,
                                color: context.themeSecondrytext,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: context.themeSecondrytext,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Section 3: Clean Dismiss Action
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.themeTextColor,
                    side: BorderSide(color: context.themeBorderColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(
                      fontFamily: poppins,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
