import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/faq_sections.dart';
import 'package:foduu_ecommerce/app/modules/helpandsupport/controllers/helpandsupport_controller.dart';
import 'package:get/get.dart';

class FaqAccordionSection extends StatelessWidget {
  final FaqAccordionSectionData data;

  const FaqAccordionSection({Key? key, required this.data}) : super(key: key);

  factory FaqAccordionSection.fromMap(Map<String, dynamic> json) {
    return FaqAccordionSection(
      data: FaqAccordionSectionData.fromMap(json),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final helpController = Get.isRegistered<HelpandsupportController>()
        ? Get.find<HelpandsupportController>()
        : null;

    if (helpController != null) {
      return Obx(() {
        final query = helpController.searchQuery.value.trim().toLowerCase();
        final selectedTopic =
            helpController.selectedTopic.value.trim().toLowerCase();

        // Topic matching filter
        if (selectedTopic.isNotEmpty &&
            !data.title.toLowerCase().contains(selectedTopic) &&
            !data.eyebrow.toLowerCase().contains(selectedTopic)) {
          // If a topic is selected and doesn't match this section title,
          // check if any of the questions match the topic
          final matchesTopic = data.items.any((item) =>
              item.question.toLowerCase().contains(selectedTopic) ||
              item.answer.toLowerCase().contains(selectedTopic));
          if (!matchesTopic) {
            return const SizedBox.shrink();
          }
        }

        // Search query filter
        final filteredItems = data.items.where((item) {
          if (query.isEmpty) return true;
          return item.question.toLowerCase().contains(query) ||
              item.answer.toLowerCase().contains(query);
        }).toList();

        if (filteredItems.isEmpty && query.isNotEmpty) {
          return const SizedBox.shrink();
        }

        return _buildSectionBody(
          context: context,
          items: filteredItems,
          theme: theme,
          colorScheme: colorScheme,
          isDark: isDark,
          helpController: helpController,
        );
      });
    }

    return _buildSectionBody(
      context: context,
      items: data.items,
      theme: theme,
      colorScheme: colorScheme,
      isDark: isDark,
      helpController: null,
    );
  }

  Widget _buildSectionBody({
    required BuildContext context,
    required List<FaqItem> items,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    required HelpandsupportController? helpController,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow & Category Title
          if (data.eyebrow.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                data.eyebrow.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: colorScheme.primary,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (data.subtitle.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    data.subtitle,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Accordion items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return _FaqAccordionCard(
                item: item,
                index: index,
                sectionKey: data.title,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FaqAccordionCard extends StatefulWidget {
  final FaqItem item;
  final int index;
  final String sectionKey;

  const _FaqAccordionCard({
    Key? key,
    required this.item,
    required this.index,
    required this.sectionKey,
  }) : super(key: key);

  @override
  State<_FaqAccordionCard> createState() => _FaqAccordionCardState();
}

class _FaqAccordionCardState extends State<_FaqAccordionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isExpanded
            ? (isDark
                ? colorScheme.surfaceContainerHigh
                : colorScheme.primary.withValues(alpha: 0.03))
            : (isDark
                ? colorScheme.surfaceContainer
                : colorScheme.surface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isExpanded
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.5),
          width: _isExpanded ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.025),
            blurRadius: _isExpanded ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: _isExpanded
                            ? colorScheme.primary
                            : colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'Q',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: _isExpanded
                                ? Colors.white
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item.question,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13.5,
                          fontWeight:
                              _isExpanded ? FontWeight.w700 : FontWeight.w600,
                          height: 1.35,
                          color: _isExpanded
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: _isExpanded
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Divider(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: isDark ? 0.25 : 0.4),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        widget.item.answer,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          height: 1.55,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
