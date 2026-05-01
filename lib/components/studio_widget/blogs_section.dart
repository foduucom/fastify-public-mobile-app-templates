import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blogs'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: pageSurroundingPadding,
          child: Column(
            children: [
              ClipRRect(
                child: CachedNetworkImage(
                    errorWidget: (context, url, error) => Container(
                          decoration:
                              BoxDecoration(color: Colors.grey.shade300),
                          child: const Center(
                            child: Icon(Icons.error),
                          ),
                        ),
                    imageUrl: HelperFunctions()
                        .getImage(widget.blogData['featured_image'])),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.blogData['name'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'lato'),
              ),
              const SizedBox(
                height: 10,
              ),
              // Text(widget.blogData['content']),
              Html(data: widget.blogData['content']),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
