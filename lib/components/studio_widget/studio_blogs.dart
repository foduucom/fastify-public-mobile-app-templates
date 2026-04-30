import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class BlogSection extends StatefulWidget {
  final dynamic blogData;

  const BlogSection({Key? key, required this.blogData}) : super(key: key);

  @override
  State<BlogSection> createState() => _BlogSectionState();
}

class _BlogSectionState extends State<BlogSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    var contentJson = widget.blogData ?? {};
    var blogs = contentJson['blogs'] ?? [];

    if (blogs.isEmpty) return const SizedBox();

    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Blogs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Get.toNamed(Routes.BLOG);
                },
                child: Text(
                  'See all',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 260, // Increased to 260 to prevent overflows
              ),
              itemCount: blogs.length,
              itemBuilder: ((context, index) {
                var blog = blogs[index];
                return InkWell(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(10)),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: HelperFunctions()
                                .getImage(blog['featured_image']),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const SizedBox(
                              child: Icon(Icons.error),
                            ),
                            progressIndicatorBuilder:
                                (context, url, progress) =>
                                    HelperFunctions().loadingIndicator(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                blog['name'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              ),
                              const SizedBox(height: 4),
                              _buildDescription(blog),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(dynamic blog) {
    String content = blog['excerpt'] ?? blog['content'] ?? '';

    return SizedBox(
      // height: 35, // Approximate height for 2 lines
      child: HtmlWidget(
        content.length > 60 ? content.substring(0, 50) + '...' : content,
        textStyle: TextStyle(
            fontSize: 12,
            fontFamily: 'Lato',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            overflow: TextOverflow
                .ellipsis // Helper for text overflow if supported by HtmlWidget context
            ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
