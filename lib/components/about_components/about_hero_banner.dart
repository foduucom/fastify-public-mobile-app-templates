import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

/// Hero header banner for the About Us page (`slider` with slug `about-us-slider`).
class AboutHeroBanner extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const AboutHeroBanner({super.key, required this.contentJson});

  @override
  Widget build(BuildContext context) {
    final slider = contentJson['slider'];
    final content = slider is Map ? slider['content'] : null;
    final Map first = (content is List && content.isNotEmpty && content.first is Map)
        ? content.first as Map
        : const {};

    final heading = (first['heading'] ?? '').toString().trim();
    final subHeading = (first['sub_heading'] ?? '').toString().trim();
    final rawPath = (first['filePath'] ??
            first['download_url'] ??
            first['url'] ??
            '')
        .toString()
        .trim();
    final imageUrl =
        rawPath.isNotEmpty ? HelperFunctions().getImage(rawPath) : '';

    final primary = Theme.of(context).colorScheme.primary;
    final title = heading.isNotEmpty ? heading : 'About Us';

    return SizedBox(
      height: 175,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            FoduuCachedNetworkImage(
              image: imageUrl,
              fit: BoxFit.cover,
              radius: 0,
            )
          else
            ColoredBox(color: primary),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primary.withValues(alpha: 0.72),
                  primary.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 13,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Home  /  About Us',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subHeading.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subHeading,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
