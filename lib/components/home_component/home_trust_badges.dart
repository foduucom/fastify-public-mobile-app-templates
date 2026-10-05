import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

/// Renders the `trust_badges` studio section.
///
/// When the cards carry no heading/text and the section has a subtitle, the
/// section is a testimonial: shown as a PageView of review cards (next card
/// peeks in) with arrows and dots. Otherwise it renders badge cards.
class TrustBadgesComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const TrustBadgesComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cards = _cards(contentJson);
    final subtitle = _str(contentJson['subtitle'] ?? contentJson['subheading']);
    final hasCardText = cards.any((c) =>
        _str(c['heading'] ?? c['title']).isNotEmpty ||
        _str(c['text'] ?? c['description']).isNotEmpty);

    if (!hasCardText && subtitle.isNotEmpty) {
      final slides = [
        _Testimonial(
          quote: _cleanQuote(subtitle),
          author: _str(contentJson['eyebrow']),
          rating: _starCount(_str(contentJson['title'])),
        ),
      ];
      final icon = cards.isNotEmpty ? cards.first['image'] : null;
      return _TestimonialCarousel(
        slides: slides,
        iconImage: icon,
        autoPlay: contentJson['auto_play'] == true,
        interval: int.tryParse('${contentJson['auto_play_interval']}') ?? 5000,
      );
    }

    if (hasCardText) {
      final reviewLike = cards.every((c) => _str(c['text']).isNotEmpty) &&
          cards.any((c) => _str(c['footer']).isNotEmpty);
      if (reviewLike) {
        return _TestimonialCarousel(
          slides: cards
              .map((c) => _Testimonial(
                    quote: _cleanQuote(_str(c['text'])),
                    author: _str(c['heading'] ?? c['title']),
                    rating: _starCount(_str(c['footer'])),
                  ))
              .toList(),
          iconImage: contentJson['icon'],
          autoPlay: contentJson['auto_play'] != false,
          interval:
              int.tryParse('${contentJson['auto_play_interval']}') ?? 5000,
        );
      }
      return _BadgeList(contentJson: contentJson, cards: cards);
    }
    return const SizedBox.shrink();
  }
}

List<Map> _cards(Map<String, dynamic> json) {
  final raw = json['cards'] ?? json['items'] ?? json['badges'];
  return raw is List ? raw.whereType<Map>().toList() : <Map>[];
}

String _str(dynamic v) => (v ?? '').toString().trim();

String _cleanQuote(String s) =>
    s.replaceAll(RegExp(r'^["“”]+|["“”]+$'), '').trim();

int _starCount(String s) {
  final n = '★'.allMatches(s).length;
  if (n > 0) return n.clamp(0, 5);
  final parsed = double.tryParse(s);
  return parsed != null ? parsed.round().clamp(0, 5) : 5;
}

class _Testimonial {
  final String quote;
  final String author;
  final int rating;
  const _Testimonial(
      {required this.quote, required this.author, required this.rating});
}

class _TestimonialCarousel extends StatefulWidget {
  final List<_Testimonial> slides;
  final dynamic iconImage;
  final bool autoPlay;
  final int interval;

  const _TestimonialCarousel({
    required this.slides,
    required this.iconImage,
    required this.autoPlay,
    required this.interval,
  });

  @override
  State<_TestimonialCarousel> createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<_TestimonialCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _page = 0;

  bool get _multi => widget.slides.length > 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _multi ? 0.88 : 1.0);
    if (widget.autoPlay && _multi) {
      _timer = Timer.periodic(Duration(milliseconds: widget.interval), (_) {
        if (!_controller.hasClients) return;
        final next = (_page + 1) % widget.slides.length;
        _controller.animateToPage(next,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final target = _page + delta;
    if (target < 0 || target >= widget.slides.length) return;
    _controller.animateToPage(target,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  double _height(double width) {
    final cardWidth = width * (_multi ? 0.88 : 1.0) - 24 - 48;
    final charsPerLine = (cardWidth / 9).floor().clamp(10, 200);
    final longest = widget.slides
        .map((s) => s.quote.length)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final lines = (longest / charsPerLine).ceil() + 1;
    return 150 + lines * 26.0;
  }

  BoxDecoration _cardDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildCardContent(
      _Testimonial s, ThemeData theme, String? iconUrl) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconUrl != null
            ? FoduuCachedNetworkImage(
                image: iconUrl,
                height: 32,
                width: 32,
                fit: BoxFit.contain,
                colorFilter: isDark
                    ? ColorFilter.mode(
                        theme.colorScheme.onSurface, BlendMode.srcIn)
                    : null,
              )
            : Icon(Icons.format_quote_rounded,
                size: 32,
                color: theme.colorScheme.primary.withOpacity(0.75)),
        const SizedBox(height: 12),
        Text(
          '"${s.quote}"',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: theme.colorScheme.onSurface,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            s.rating,
            (_) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.5),
              child: Icon(Icons.star_rounded,
                  size: 17, color: Color(0xFFFF9800)),
            ),
          ),
        ),
        if (s.author.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded,
                    size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 5),
                Text(
                  s.author,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final iconUrl = widget.iconImage == null ||
            _str(widget.iconImage is Map
                    ? widget.iconImage['url']
                    : widget.iconImage)
                .isEmpty
        ? null
        : HelperFunctions().getImage(widget.iconImage);

    if (!_multi) {
      final s = widget.slides.first;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: _cardDecoration(theme),
          child: _buildCardContent(s, theme, iconUrl),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 28),
      child: Column(
        children: [
          SizedBox(
            height: _height(width),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final s = widget.slides[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: _cardDecoration(theme),
                    child: _buildCardContent(s, theme, iconUrl),
                  ),
                );
              },
            ),
          ),
          if (_multi) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _arrow(Icons.chevron_left, _page > 0 ? () => _go(-1) : null),
                const SizedBox(width: 16),
                ...List.generate(widget.slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 8,
                    width: active ? 24 : 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: active
                          ? theme.primaryColor
                          : theme.colorScheme.outlineVariant,
                    ),
                  );
                }),
                const SizedBox(width: 16),
                _arrow(
                    Icons.chevron_right,
                    _page < widget.slides.length - 1 ? () => _go(1) : null),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _arrow(IconData icon, VoidCallback? onTap) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Icon(icon,
            size: 20,
            color: onTap == null
                ? Theme.of(context).disabledColor
                : Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _BadgeList extends StatelessWidget {
  final Map<String, dynamic> contentJson;
  final List<Map> cards;

  const _BadgeList({required this.contentJson, required this.cards});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _str(contentJson['title'] ?? contentJson['heading']);
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
          ],
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final c = cards[i];
                final image = c['image'] ?? c['icon'];
                return Container(
                  width: 190,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.4)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (image != null && _str(image).isNotEmpty)
                        FoduuCachedNetworkImage(
                            image: HelperFunctions().getImage(image),
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                            colorFilter: theme.brightness == Brightness.dark
                                ? ColorFilter.mode(
                                    theme.colorScheme.onSurface,
                                    BlendMode.srcIn)
                                : null),
                      const SizedBox(height: 10),
                      Text(_str(c['heading'] ?? c['title']),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(_str(c['text'] ?? c['description']),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
