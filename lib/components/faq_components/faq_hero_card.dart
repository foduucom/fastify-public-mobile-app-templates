import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/faq_sections.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

class FaqHeroCard extends StatelessWidget {
  final FaqHeroData data;

  const FaqHeroCard({Key? key, required this.data}) : super(key: key);

  factory FaqHeroCard.fromMap(Map<String, dynamic> json) {
    return FaqHeroCard(data: FaqHeroData.fromMap(json));
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
                        heroSurface.withValues(alpha: 0.78),
                        heroSurface.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (data.title.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Text(
                            data.title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (data.subtitle.isNotEmpty)
                        Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                        ),
                      if (data.description.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    ],
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
