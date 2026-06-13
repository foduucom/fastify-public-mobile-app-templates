import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class BlogSection extends StatefulWidget {
  var blogData;
  BlogSection({super.key, required this.blogData});

  @override
  State<BlogSection> createState() => _BlogSectionState();
}

class _BlogSectionState extends State<BlogSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var blogs = widget.blogData['blogs'] ?? [];
    final title = widget.blogData['heading'] ?? 'Blogs';
    final displayTitle = title.toString().isEmpty ? 'Blogs' : title.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(displayTitle),
      ),
      body: blogs.isEmpty
          ? const Center(child: Text("No blogs available"))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: blogs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 240,
              ),
              itemBuilder: (context, index) {
                var blog = blogs[index];
                return InkWell(
                  onTap: () {
                    final blogId = blog['_id'] ?? blog['id'];
                    if (blogId != null) {
                      Get.toNamed(Routes.BLOG_DETAILS,
                          arguments: {'id': blogId});
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10)),
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
              },
            ),
    );
  }

  Widget _buildDescription(dynamic blog) {
    String content = blog['excerpt'] ?? blog['content'] ?? '';
    return SizedBox(
      child: HtmlWidget(
        content.length > 60 ? content.substring(0, 50) + '...' : content,
        textStyle: TextStyle(
            fontSize: 12,
            fontFamily: 'Lato',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
