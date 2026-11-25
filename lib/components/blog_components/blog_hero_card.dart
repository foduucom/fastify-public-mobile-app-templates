import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/blog_sections.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

class BlogHeroCard extends StatelessWidget {
  final BlogHeroHeaderData data;

  const BlogHeroCard({Key? key, required this.data}) : super(key: key);

  factory BlogHeroCard.fromMap(Map<String, dynamic> json) {
    return BlogHeroCard(data: BlogHeroHeaderData.fromMap(json));
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = data.imagePath.isNotEmpty
        ? HelperFunctions().getImage(data.imagePath)
        : '';
    final colorScheme = Theme.of(context).colorScheme;
    final heroSurface = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: heroSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              if (imageUrl.isNotEmpty)
                Positioned.fill(
                  child: FoduuCachedNetworkImage(
                    image: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        heroSurface.withValues(alpha: 0.72),
                        heroSurface.withValues(alpha: 0.90),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (data.title.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          data.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (data.subtitle.isNotEmpty)
                      Text(
                        data.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.3,
                          height: 1.25,
                        ),
                      ),
                    if (data.description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
