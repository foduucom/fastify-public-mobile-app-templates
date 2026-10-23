import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/components/shimmer_effects.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/home_component/blog_card.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

class BlogSection extends StatefulWidget {
  final String title;
  final String? subTitle;
  final dynamic blogList;
  final bool isLoading;
  final String seeAllText;
  final bool isPillSeeAll;
  final EdgeInsetsGeometry? headerPadding;
  final VoidCallback? onSeeAllTap;
  final Function(dynamic blog)? onBlogTap;

  const BlogSection({
    Key? key,
    this.title = 'Blogs',
    this.subTitle,
    required this.blogList,
    required this.isLoading,
    this.seeAllText = 'See All',
    this.isPillSeeAll = false,
    this.headerPadding,
    this.onSeeAllTap,
    this.onBlogTap,
  }) : super(key: key);

  @override
  State<BlogSection> createState() => _BlogSectionState();
}

class _BlogSectionState extends State<BlogSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool hasItems = widget.blogList != null && widget.blogList.isNotEmpty;

    if (!hasItems && !widget.isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: widget.headerPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: context.themeTextColor,
                      ),
                    ),
                    if (widget.subTitle != null &&
                        widget.subTitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subTitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: themeSecondrytext,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onSeeAllTap ?? () => Get.toNamed(Routes.BLOG),
                child: widget.isPillSeeAll
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themePrimaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.seeAllText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: themePrimaryColor,
                          ),
                        ),
                      )
                    : Text(
                        widget.seeAllText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: themeSecondrytext,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 285,
          child: widget.isLoading && !hasItems
              ? const BlogsShimmer()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: widget.blogList.length,
                  itemBuilder: (context, index) {
                    final blog = widget.blogList[index];
                    return BlogCard(
                      blog: blog,
                      onTap: widget.onBlogTap != null
                          ? () => widget.onBlogTap!(blog)
                          : null,
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BlogsShimmer extends StatelessWidget {
  const BlogsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        itemCount: 4,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 145,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8EEF5),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EEF5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EEF5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EEF5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
