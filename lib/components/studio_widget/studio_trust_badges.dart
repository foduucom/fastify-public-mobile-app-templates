import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'studio_common_widgets.dart';

class TrustBadgesComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const TrustBadgesComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rawCards = contentJson['cards'] ?? contentJson['items'] ?? contentJson['badges'];
    if (rawCards is! List || rawCards.isEmpty) return const SizedBox.shrink();

    final validCards = rawCards.whereType<Map>().toList();
    if (validCards.isEmpty) return const SizedBox.shrink();

    final eyebrow = (contentJson['eyebrow'] ?? '').toString().trim();
    final title = (contentJson['title'] ?? contentJson['heading'] ?? '').toString().trim();
    final subtitle = (contentJson['subtitle'] ?? contentJson['subheading'] ?? '').toString().trim();

    final viewMode = (contentJson['view'] ?? 'grid').toString();
    final listViewType = (contentJson['list_view_type'] ?? 'horizontal').toString();

    int requestedColumns =
        int.tryParse(contentJson['no_of_columns']?.toString() ?? contentJson['columns']?.toString() ?? '4') ?? 4;
    if (requestedColumns < 1) requestedColumns = 1;
    if (requestedColumns > 4) requestedColumns = 4;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isHorizontalList = viewMode == 'list' || listViewType == 'horizontal';

    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow.isNotEmpty || title.isNotEmpty) ...[
            _buildHeader(context, eyebrow, title, subtitle, colorScheme, textTheme),
            const SizedBox(height: 14),
          ],
          if (isHorizontalList)
            _buildHorizontalListView(context, validCards, colorScheme, textTheme)
          else
            _buildGridView(context, validCards, requestedColumns, screenWidth, colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String eyebrow,
    String title,
    String subtitle,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (eyebrow.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 24, height: 1, color: colorScheme.primary.withValues(alpha: 0.4)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  eyebrow.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    letterSpacing: 2.0,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(width: 24, height: 1, color: colorScheme.primary.withValues(alpha: 0.4)),
            ],
          ),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      );
    }

    return StudioSectionHeader(
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildHorizontalListView(
    BuildContext context,
    List<Map> cards,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SizedBox(
      height: 180,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 210,
              child: _buildCard(context, cards[index], colorScheme, textTheme),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    List<Map> cards,
    int requestedColumns,
    double screenWidth,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    int crossAxisCount = requestedColumns;
    if (screenWidth < 600 && crossAxisCount > 2) {
      crossAxisCount = 2;
    }
    if (cards.length < crossAxisCount) {
      crossAxisCount = cards.length;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: crossAxisCount == 1 ? 2.5 : 0.92,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return _buildCard(context, cards[index], colorScheme, textTheme);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    Map card,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final heading = (card['heading'] ?? card['title'] ?? '').toString().trim();
    final text = (card['text'] ?? card['subtitle'] ?? card['description'] ?? '').toString().trim();
    final image = card['image'] ?? card['icon'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: image == null || image.toString().isEmpty
                  ? Icon(
                      _getFallbackIcon(heading),
                      color: colorScheme.primary,
                      size: 24,
                    )
                  : FoduuCachedNetworkImage(
                      image: HelperFunctions().getImage(image),
                      height: 24,
                      width: 24,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          if (heading.isNotEmpty)
            Text(
              heading,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFallbackIcon(String heading) {
    final lower = heading.toLowerCase();
    if (lower.contains('hallmark') || lower.contains('bis') || lower.contains('purity')) {
      return Icons.verified_outlined;
    }
    if (lower.contains('buyback') || lower.contains('exchange') || lower.contains('return')) {
      return Icons.published_with_changes_rounded;
    }
    if (lower.contains('diamond') || lower.contains('certif') || lower.contains('stone')) {
      return Icons.workspace_premium_outlined;
    }
    if (lower.contains('ship') || lower.contains('delivery') || lower.contains('insur')) {
      return Icons.local_shipping_outlined;
    }
    return Icons.verified_user_outlined;
  }
}

