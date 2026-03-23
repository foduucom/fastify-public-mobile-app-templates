import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app/modules/auth/login/views/widgets/app_text_styles.dart';
import '../../app_colors.dart';


enum SocialType { google, facebook }

class SocialButton extends StatelessWidget {
  final SocialType type;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = type == SocialType.google
        ? 'Sign Up with Google'
        : 'Sign Up with Facebook';

    final icon = type == SocialType.google
        ? FontAwesomeIcons.google
        : FontAwesomeIcons.facebookF;

    final iconColor = type == SocialType.google
        ? AppColors.googleRed
        : AppColors.facebookBlue;

    final iconBgColor = type == SocialType.google
        ? AppColors.googleRed.withOpacity(0.0)
        : AppColors.facebookBlue;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.socialButtonBg,
          side: const BorderSide(color: AppColors.socialButtonBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Facebook uses a circular colored container, Google is plain icon
            type == SocialType.facebook
                ? Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: AppColors.socialButtonBg,
                  size: 16,
                ),
              ),
            )
                : FaIcon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.socialButton),
          ],
        ),
      ),
    );
  }
}
