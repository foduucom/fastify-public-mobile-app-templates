import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/productdetial_controller.dart';
import 'package:foduu_ecommerce/components/review.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart'; // Make sure to import your custom widget

class AllReview extends StatelessWidget {
  List reviewData;
  ProductdetialController controller;
  String name;
  int rating;
  AllReview(
      {Key? key,
      required this.reviewData,
      required this.controller,
      required this.name,
      required this.rating})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'All Review  (${reviewData.length})',
            style: TextStyle(fontFamily: 'lato', fontSize: 16),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: pageSurroundingPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     CachedNetworkImage(
                //       width: 150,
                //       height: 150,
                //       fit: BoxFit.cover,
                //       imageUrl: controller.productDetials['featured_image'] ==
                //               null
                //           ? 'https://st4.depositphotos.com/14953852/24787/v/450/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg'
                //           : url +
                //               controller.productDetials['featured_image']
                //                   ['filepath'],
                //       placeholder: (context, url) =>
                //           const CircularProgressIndicator(),
                //       errorWidget: (context, url, error) =>
                //           const Icon(Icons.error),
                //     ),
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           name,
                //           maxLines: 2,
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //         RatingBarIndicator(
                //           // rating: widget.controller.productDetials['average_rating'] == null
                //           //         ? 3.0
                //           //         : double.parse(widget.controller
                //           //             .productDetials['average_rating']
                //           //             .toString()),
                //           rating: 4.3,
                //           itemBuilder: (context, index) => const Icon(
                //             Icons.star,
                //             color: Colors.amber,
                //           ),
                //           itemCount: 5,
                //           itemSize: 18.0,
                //           direction: Axis.horizontal,
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                // const Divider(),
                ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  shrinkWrap: true,
                  itemCount: reviewData.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return customerReview(
                        profileimage: reviewData[index]['customer']
                                    ['featured_image'] ==
                                null
                            ? HelperFunctions.getNoImage()
                            : url +
                                reviewData[index]['customer']['featured_image']
                                    ['filepath'],
                        name:
                            "${reviewData[index]['customer']['name'].toString()} | ${controller.getDate(reviewData[index]['updated_at'])}",
                        review: reviewData[index]['summary'],
                        rating: reviewData[index]['rating']);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
