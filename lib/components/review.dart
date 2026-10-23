import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../constants/theme_ext.dart';

class customerReview extends StatelessWidget {
  customerReview({
    Key? key,
    required this.profileimage,
    required this.name,
    required this.review,
    required this.rating,
  }) : super(key: key);

  final String profileimage;
  final String name;
  final int rating;
  final String review;

  Widget _buildAvatar(String displayName) {
    bool hasValidImage = profileimage.isNotEmpty &&
        !profileimage.contains("no-photo-or-blank-image-icon") &&
        !profileimage.contains("no-image-available-icon") &&
        profileimage.startsWith("http");

    if (hasValidImage) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: themeTextColor.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profileimage,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: context.themegreyColor,
              child: const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: themePrimaryColor,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) =>
                _buildInitialsAvatar(displayName),
          ),
        ),
      );
    }

    return _buildInitialsAvatar(displayName);
  }

  Widget _buildInitialsAvatar(String name) {
    final firstLetter =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'G';

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: themeRedColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: themeWhiteColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int ratingValue = rating.clamp(0, 5);

    String displayName = name;
    String? displayDate;
    if (name.contains(" | ")) {
      final parts = name.split(" | ");
      displayName = parts[0].trim();
      displayDate = parts[1].trim();
    }
    if (displayName.isEmpty) {
      displayName = 'Guest';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(displayName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.themeTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (displayDate != null)
                        Text(
                          displayDate,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: context.themeSecondrytext,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        color: index < ratingValue
                            ? const Color(0xFFFFA800)
                            : const Color(0xFFEDEFF4),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (review.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(
                left: 56), // Offset by avatar size (44) + spacing (12)
            child: Text(
              review.trim(),
              style: TextStyle(
                color: context.themeTextColor.withOpacity(0.7),
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
