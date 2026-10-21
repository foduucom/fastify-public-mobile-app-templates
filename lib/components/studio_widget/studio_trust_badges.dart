import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/constants/constants.dart';
import 'studio_common_widgets.dart';

class TrustBadgesComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const TrustBadgesComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rawCards =
        contentJson['cards'] ?? contentJson['items'] ?? contentJson['badges'];
    if (rawCards is! List || rawCards.isEmpty) return const SizedBox.shrink();

    final validCards = rawCards.whereType<Map>().toList();
    if (validCards.isEmpty) return const SizedBox.shrink();

    final eyebrow = (contentJson['eyebrow'] ?? '').toString().trim();
    final title =
        (contentJson['title'] ?? contentJson['heading'] ?? '').toString().trim();
    final subtitle = (contentJson['subtitle'] ?? contentJson['subheading'] ?? '')
        .toString()
        .trim();


    int requestedColumns = int.tryParse(contentJson['no_of_columns']?.toString() ??
            contentJson['columns']?.toString() ??
            '4') ??
        4;
    if (requestedColumns < 1) requestedColumns = 1;
    if (requestedColumns > 4) requestedColumns = 4;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final hasExplicitColumns = contentJson.containsKey('no_of_columns') ||
        contentJson.containsKey('columns');
    final isExplicitGrid = contentJson['view'] == 'grid' || hasExplicitColumns;
    final bool isHorizontalList = !isExplicitGrid &&
        (contentJson['view'] == 'list' ||
            contentJson['list_view_type'] == 'horizontal');

    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow.isNotEmpty || title.isNotEmpty) ...[
            _buildHeader(
                context, eyebrow, title, subtitle, colorScheme, textTheme),
            const SizedBox(height: 14),
          ],
          if (isHorizontalList)
            _buildHorizontalListView(context, validCards, colorScheme, textTheme)
          else
            _buildGridView(context, validCards, requestedColumns, screenWidth,
                colorScheme, textTheme),
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
              Container(
                  width: 24,
                  height: 1,
                  color: colorScheme.primary.withValues(alpha: 0.4)),
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
              Container(
                  width: 24,
                  height: 1,
                  color: colorScheme.primary.withValues(alpha: 0.4)),
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
        childAspectRatio: crossAxisCount == 1 ? 2.4 : 0.95,
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
    final text =
        (card['text'] ?? card['subtitle'] ?? card['description'] ?? '')
            .toString()
            .trim();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Crisp vector icon directly on card
          SizedBox(
            height: 34,
            width: 34,
            child: Center(
              child: _buildWebsiteIcon(heading, iconColor),
            ),
          ),
          const SizedBox(height: 10),
          if (heading.isNotEmpty)
            Text(
              heading,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.2,
                color: colorScheme.onSurface,
              ),
            ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 5),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? const Color(0xFF9E9E9E)
                      : colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWebsiteIcon(String heading, Color iconColor) {
    final lower = heading.toLowerCase();

    // 1. "Sustainable Fabrics" -> Clean bold checkmark (Image 2)
    if (lower.contains('fabric') ||
        lower.contains('cotton') ||
        lower.contains('sustain') ||
        lower.contains('check')) {
      return CleanCheckmarkIcon(color: iconColor, size: 28);
    }

    // 2. "Timeless Design, Not Trends" -> Solid black star (Image 2)
    if (lower.contains('timeless') ||
        lower.contains('trend') ||
        lower.contains('design') ||
        lower.contains('star')) {
      return Icon(
        Icons.star_rounded,
        size: 32,
        color: iconColor,
      );
    }

    // 3. "Eco-Conscious Production" -> 3D Isometric outline cube (Image 2)
    if (lower.contains('eco') ||
        lower.contains('product') ||
        lower.contains('planet') ||
        lower.contains('box') ||
        lower.contains('cube')) {
      return IsometricCubeIcon(color: iconColor, size: 28);
    }

    // 4. "Effortless Versatility" -> Clean outline heart (Image 2)
    if (lower.contains('versatil') ||
        lower.contains('wardrobe') ||
        lower.contains('heart') ||
        lower.contains('effort')) {
      return Icon(
        Icons.favorite_border_rounded,
        size: 28,
        color: iconColor,
      );
    }

    return Icon(
      Icons.verified_outlined,
      size: 28,
      color: iconColor,
    );
  }
}

class CleanCheckmarkIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const CleanCheckmarkIcon({
    Key? key,
    this.size = 28.0,
    required this.color,
    this.strokeWidth = 2.4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CheckmarkPainter(color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.74)
      ..lineTo(size.width * 0.78, size.height * 0.28);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

class IsometricCubeIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const IsometricCubeIcon({
    Key? key,
    this.size = 28.0,
    required this.color,
    this.strokeWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IsometricCubePainter(color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _IsometricCubePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _IsometricCubePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;
    final dx = r * 0.866; // cos(30 deg)
    final dy = r * 0.5; // sin(30 deg)

    // Outer hexagon path
    final path = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + dx, cy - dy)
      ..lineTo(cx + dx, cy + dy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - dx, cy + dy)
      ..lineTo(cx - dx, cy - dy)
      ..close();

    // 3 inner radial lines meeting at center
    path.moveTo(cx, cy);
    path.lineTo(cx, cy + r);

    path.moveTo(cx, cy);
    path.lineTo(cx - dx, cy - dy);

    path.moveTo(cx, cy);
    path.lineTo(cx + dx, cy - dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IsometricCubePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
