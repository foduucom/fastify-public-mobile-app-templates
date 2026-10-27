import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/models/about_us_sections.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

import '../controllers/aboutus_controller.dart';

class AboutusView extends GetView<AboutusController> {
  const AboutusView({Key? key}) : super(key: key);

  static const _poppins = 'Poppins';

  String _imageUrl(String path) {
    if (path.isEmpty) return '';
    return HelperFunctions().getImage(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        backgroundColor: context.themeWhiteColor,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: context.themeTextColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: _poppins,
            fontSize: 17,
            color: context.themetitleColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.support_agent_rounded,
              color: context.themePrimaryColor,
              size: 24,
            ),
            tooltip: 'Contact Support',
            onPressed: controller.goToContact,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.rawSections.isEmpty &&
            controller.story.value.description.isEmpty) {
          return Center(child: HelperFunctions().loadingIndicator());
        }

        final header = controller.header.value;
        final story = controller.story.value;
        final whyChoose = controller.whyChoose.value;
        final process = controller.process.value;
        final testimonials = controller.testimonials.value;

        return RefreshIndicator(
          onRefresh: controller.fetchAboutUs,
          color: context.themePrimaryColor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 36),
            children: [
              _buildHeroBanner(context, header),
              const SizedBox(height: 16),
              _buildStorySection(context, story),
              const SizedBox(height: 28),
              _buildWhyChooseSection(context, whyChoose),
              const SizedBox(height: 28),
              _buildProcessSection(context, process),
              if (testimonials.items.isNotEmpty) ...[
                const SizedBox(height: 28),
                _buildTestimonialsSection(context, testimonials),
              ],
            ],
          ),
        );
      }),
    );
  }

  // MARK: - 1. Hero Header Banner
  Widget _buildHeroBanner(BuildContext context, AboutHeroHeader header) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (header.backgroundImage.isNotEmpty)
            CachedNetworkImage(
              imageUrl: _imageUrl(header.backgroundImage),
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(color: const Color(0xFF12253D)),
            )
          else
            Container(color: const Color(0xFF12253D)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A192D).withValues(alpha: 0.78),
                  const Color(0xFF12253D).withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_outlined,
                          size: 13, color: Colors.white70),
                      SizedBox(width: 4),
                      Text(
                        'Home  /  About Us',
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  header.title,
                  style: const TextStyle(
                    fontFamily: _poppins,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - 2. Story Section
  Widget _buildStorySection(BuildContext context, AboutHeroStory story) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.themeBorderColor),
          boxShadow: cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story.bannerImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _imageUrl(story.bannerImage),
                  width: double.infinity,
                  height: 185,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 185,
                    color: context.themegreyColor,
                    child: Center(child: HelperFunctions().loadingIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 185,
                    color: context.themegreyColor,
                    child: Center(
                      child: Icon(
                        Icons.business_rounded,
                        size: 48,
                        color: context.themeSecondrytext.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text(
              story.title,
              style: TextStyle(
                fontFamily: _poppins,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: context.themetitleColor,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              story.description,
              style: TextStyle(
                fontFamily: _poppins,
                fontSize: 13.5,
                height: 1.6,
                color: context.themeSecondrytext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - 3. Why Choose Vision Infrastructure
  Widget _buildWhyChooseSection(
      BuildContext context, AboutWhyChooseSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEyebrowBadge(context, section.eyebrow),
          const SizedBox(height: 6),
          Text(
            section.title,
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: context.themetitleColor,
            ),
          ),
          if (section.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              section.subtitle,
              style: TextStyle(
                fontFamily: _poppins,
                fontSize: 13,
                color: context.themeSecondrytext,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...section.features.map((feature) {
            final iconData = _getWhyChooseIcon(feature.iconKey);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.themeWhiteColor,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: context.themeBorderColor),
                  boxShadow: cardShadow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.themePrimaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              context.themePrimaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: feature.imageUrl.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: CachedNetworkImage(
                                imageUrl: _imageUrl(feature.imageUrl),
                                fit: BoxFit.contain,
                                color: context.themePrimaryColor,
                                placeholder: (_, __) => Icon(
                                  iconData,
                                  color: context.themePrimaryColor,
                                  size: 21,
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  iconData,
                                  color: context.themePrimaryColor,
                                  size: 21,
                                ),
                              ),
                            )
                          : Icon(
                              iconData,
                              color: context.themePrimaryColor,
                              size: 21,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.title,
                            style: TextStyle(
                              fontFamily: _poppins,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.themetitleColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feature.description,
                            style: TextStyle(
                              fontFamily: _poppins,
                              fontSize: 13,
                              height: 1.5,
                              color: context.themeSecondrytext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _getWhyChooseIcon(String key) {
    switch (key.toLowerCase()) {
      case 'verification':
      case 'quality':
        return Icons.verified_rounded;
      case 'headset':
      case 'support':
        return Icons.support_agent_rounded;
      case 'truck':
      case 'delivery':
        return Icons.local_shipping_rounded;
      case 'tags':
      case 'pricing':
        return Icons.local_offer_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  // MARK: - 5. Our Process (Vertical Connected Timeline)
  Widget _buildProcessSection(
      BuildContext context, AboutProcessSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEyebrowBadge(context, section.eyebrow),
          const SizedBox(height: 6),
          Text(
            section.title,
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: context.themetitleColor,
            ),
          ),
          if (section.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              section.subtitle,
              style: TextStyle(
                fontFamily: _poppins,
                fontSize: 13,
                color: context.themeSecondrytext,
              ),
            ),
          ],
          const SizedBox(height: 18),
          ...section.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == section.steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: context.themePrimaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.themePrimaryColor
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            step.stepNumber,
                            style: const TextStyle(
                              fontFamily: _poppins,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: context.themePrimaryColor
                                .withValues(alpha: 0.25),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.themeWhiteColor,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: context.themeBorderColor),
                          boxShadow: cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontFamily: _poppins,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.themetitleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.description,
                              style: TextStyle(
                                fontFamily: _poppins,
                                fontSize: 13,
                                height: 1.5,
                                color: context.themeSecondrytext,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // MARK: - 6. Testimonials Carousel
  Widget _buildTestimonialsSection(
      BuildContext context, AboutTestimonialsSection section) {
    if (section.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEyebrowBadge(context, section.eyebrow),
          const SizedBox(height: 6),
          Text(
            section.title,
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: context.themetitleColor,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: section.items.length,
              onPageChanged: (i) =>
                  controller.currentTestimonialIndex.value = i,
              itemBuilder: (ctx, idx) {
                final item = section.items[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.themeWhiteColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.themeBorderColor),
                      boxShadow: cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              size: 28,
                              color: context.themePrimaryColor
                                  .withValues(alpha: 0.85),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (star) => Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: star < item.rating.floor()
                                      ? context.themeYellowColor
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            '"${item.review}"',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: _poppins,
                              fontSize: 13,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                              color: context.themeSecondrytext,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: item.avatarUrl,
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => CircleAvatar(
                                  radius: 19,
                                  backgroundColor: context.themePrimaryColor
                                      .withValues(alpha: 0.15),
                                  child: Text(
                                    item.name.isNotEmpty
                                        ? item.name[0].toUpperCase()
                                        : 'V',
                                    style: TextStyle(
                                      fontFamily: _poppins,
                                      fontWeight: FontWeight.bold,
                                      color: context.themePrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontFamily: _poppins,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: context.themetitleColor,
                                    ),
                                  ),
                                  Text(
                                    item.role,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: _poppins,
                                      fontSize: 11.5,
                                      color: context.themeSecondrytext,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(section.items.length, (dotIdx) {
                final isSelected =
                    controller.currentTestimonialIndex.value == dotIdx;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isSelected ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.themePrimaryColor
                        : context.themeBorderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  // MARK: - Helper Eyebrow Badge
  Widget _buildEyebrowBadge(BuildContext context, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: context.themePrimaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: _poppins,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.themePrimaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
