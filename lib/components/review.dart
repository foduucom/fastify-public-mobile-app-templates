import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/constants.dart';
import '../constants/helper_functions.dart';
import 'app_image_placeholder.dart';

class customerReview extends StatelessWidget {
  customerReview({
    Key? key,
    required this.profileimage,
    required this.name,
    required this.review,
    required this.rating,
  }) : super(key: key);
  String profileimage;
  String name;
  int rating;
  String review;

  @override
  Widget build(BuildContext context) {
    // int ratingValue = int.tryParse(rating) ?? 0;
    int ratingValue = rating.clamp(0, 5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 60,
                height: 60,
                child: (profileimage.isNotEmpty &&
                        profileimage != HelperFunctions.getNoImage())
                    ? CachedNetworkImage(
                        imageUrl: profileimage,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const AppImagePlaceholder.circular(size: 60),
                      )
                    : const AppImagePlaceholder.circular(size: 60),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontFamily: 'Lato', fontSize: 14)),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < ratingValue ? Icons.star : Icons.star,
                      color: index < ratingValue
                          ? const Color(0xFFFFBA49)
                          : Color.fromRGBO(237, 239, 244, 1),
                      size: 16,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 10),
        Text(review, style: TextStyle(fontFamily: 'lato', fontSize: 14)),
        const SizedBox(height: 10),
        // Row(
        //   children: [
        //     Container(
        //       decoration: BoxDecoration(
        //           color: themegreyColor,
        //           borderRadius: BorderRadius.circular(3)),
        //       child: const Padding(
        //         padding: EdgeInsets.all(6.0),
        //         child: Text("Size bought: S",
        //             style: TextStyle(fontFamily: 'lato', fontSize: 12)),
        //       ),
        //     ),
        //     const Spacer(),
        //     SvgPicture.asset("assets/icon/reviewicon.svg"),
        //     const SizedBox(width: 10),
        //     const Text("20",
        //         style: TextStyle(
        //             fontFamily: 'lato',
        //             fontSize: 14,
        //             color: themeSecondrytext)),
        //     const SizedBox(width: 10),
        //     SvgPicture.asset("assets/icon/reviewiocn1.svg"),
        //     const SizedBox(width: 10),
        //     const Text("2",
        //         style: TextStyle(
        //             fontFamily: 'lato',
        //             fontSize: 14,
        //             color: themeSecondrytext)),
        //     const SizedBox(width: 10),
        //   ],
        // )
      ],
    );
  }
}
