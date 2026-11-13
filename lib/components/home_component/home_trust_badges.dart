import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';
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
      final isPromo = cards.any((c) {
        final f = _str(c['footer']).toLowerCase();
        return f.contains('shop') || f.contains('deal') || f.contains('now');
      });
      if (isPromo) {
        return _PromoCardList(contentJson: contentJson, cards: cards);
      }

      final reviewLike = cards.every((c) => _str(c['text']).isNotEmpty) &&
          cards.any((c) => _isRatingString(_str(c['footer'])));
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

bool _isRatingString(String s) {
  final clean = s.trim();
  if (clean.isEmpty) return false;
  if (clean.contains('★')) return true;
  final num = double.tryParse(clean);
  return num != null && num >= 1 && num <= 5;
}

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

class _PromoCardList extends StatelessWidget {
  final Map<String, dynamic> contentJson;
  final List<Map> cards;

  const _PromoCardList({required this.contentJson, required this.cards});

  Map<String, String> _splitHeading(String raw) {
    for (final tag in [
      'Hot Pick',
      'Deal of the Day',
      'Fitness Deal',
      'Best Value',
      'Top Rated'
    ]) {
      if (raw.startsWith(tag)) {
        return {'tag': tag, 'title': raw.substring(tag.length).trim()};
      }
    }
    return {'tag': '', 'title': raw};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final title = _str(contentJson['title'] ?? contentJson['heading']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(
            height: 148,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final c = cards[i];
                final rawHeading = _str(c['heading'] ?? c['title']);
                final split = _splitHeading(rawHeading);
                final tag = split['tag']!;
                final cardTitle = split['title']!;
                final desc = _str(c['text'] ?? c['description']);
                final image = c['image'] ?? c['icon'];
                final imageUrl =
                    image != null ? HelperFunctions().getImage(image) : '';

                Color cardBg;
                if (isDark) {
                  cardBg = colorScheme.surface;
                } else {
                  switch (i % 3) {
                    case 0:
                      cardBg = const Color(0xFFF1F5F9);
                      break;
                    case 1:
                      cardBg = const Color(0xFFFDF2F8);
                      break;
                    case 2:
                    default:
                      cardBg = const Color(0xFFF0FDF4);
                      break;
                  }
                }

                return GestureDetector(
                  onTap: () {
                    openShop({
                      'name': cardTitle.isNotEmpty ? cardTitle : rawHeading,
                      'source': 'promo'
                    });
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width * 0.82)
                        .clamp(285.0, 325.0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: colorScheme.outline.withOpacity(0.14)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (tag.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2.5),
                                  margin: const EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              Text(
                                cardTitle.isNotEmpty ? cardTitle : rawHeading,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                  height: 1.2,
                                ),
                              ),
                              if (desc.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  desc,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Shop Now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded,
                                      size: 13, color: colorScheme.primary),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 95,
                              height: 95,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.image_outlined),
                                progressIndicatorBuilder: (_, __, ___) =>
                                    HelperFunctions().loadingIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
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

class _BadgeList extends StatelessWidget {
  final Map<String, dynamic> contentJson;
  final List<Map> cards;

  const _BadgeList({required this.contentJson, required this.cards});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final title = _str(contentJson['title'] ?? contentJson['heading']);
    final eyebrow = _str(contentJson['eyebrow']);

    final bool isBrandRow =
        cards.every((c) => _str(c['text'] ?? c['description']).isEmpty);

    if (isBrandRow) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow.isNotEmpty || title.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow.isNotEmpty)
                      Text(
                        eyebrow.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: colorScheme.primary,
                        ),
                      ),
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final c = cards[i];
                  final image = c['image'] ?? c['icon'];
                  final imageUrl =
                      image != null ? HelperFunctions().getImage(image) : '';
                  final brandName = _str(c['heading'] ?? c['title']);

                  return GestureDetector(
                    onTap: () {
                      openShop({'name': brandName, 'source': 'brand'});
                    },
                    child: Container(
                      width: 126,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.14),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (imageUrl.isNotEmpty)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) => const Icon(
                                      Icons.business_outlined,
                                      size: 26),
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            brandName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

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
