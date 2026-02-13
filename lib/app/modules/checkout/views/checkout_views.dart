import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/helpers/dialog_helper.dart';
import 'package:get/get.dart';

class CheckoutViews extends GetView<CheckoutViews> {
  const CheckoutViews({super.key});

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return Scaffold(
      body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.02,
          ),
          child: Column(
            children: [
              SizedBox(height: height * 0.02),
              //HEADER PAGE
              SecondaryAppHeader(
                title: "Checkout",
                showRight: false,
              ),
              SizedBox(height: height * 0.02),
              // ADDRESS BAR
              Container(
                width: width * 0.94,
                height: height * 0.086,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.026,
                  vertical: height * 0.012,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height * 0.015), // ≈ 12
                  border: Border.all(
                    color: DefaultThemeColors.darklight,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: height * 0.056, // ≈ 45
                      height: height * 0.056, // ≈ 45
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(height * 0.01), // ≈ 8
                      ),
                      alignment: Alignment.center,
                      child: Center(
                        child: Icon(
                          Icons.location_on_outlined,
                          size: height * 0.0315, // ≈ 25.2
                          color: DefaultThemeColors.secondarymain,
                        ),
                      ),
                    ),

                    SizedBox(width: width * 0.025), // ≈ gap 10

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Your Address",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: height * 0.018, // ≈ 14
                              fontWeight: FontWeight.w600,
                              height: 1.3, // ≈ 20
                            ),
                          ),
                          SizedBox(height: height * 0.004),
                          Text(
                            "Historical st, West Anderson 43. CA",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: height * 0.015, // ≈ 12
                              fontWeight: FontWeight.w500,
                              height: 2, // ≈ 24
                              color: DefaultThemeColors.lightDarker,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: height * 0.035, // ≈ 20
                      height: height * 0.035, // ≈ 20
                      child: Icon(
                        Icons.edit_outlined,
                        size: height * 0.02, // ≈ 15.5
                        color: DefaultThemeColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.01),

              Container(
                width: width * 0.92, // ≈ 345
                height: height * 0.54, // ≈ 408
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width * 0.36, // ≈ 134
                      child: Text(
                        "Payment Method",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: height * 0.02, // ≈ 16
                          fontWeight: FontWeight.w700,
                          height: 1.75, // ≈ 28
                          color: const Color(0xFF232323),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.015), // gap 12
                    Container(
                      width: width * 0.92,
                      height: height * 0.065, // ≈ 52
                      padding: EdgeInsets.all(width * 0.03), // ≈ 12
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height * 0.015),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/paypal.png",
                            width: height * 0.035, // ≈ 28
                            height: height * 0.035,
                          ),
                          SizedBox(width: width * 0.03),
                          SizedBox(
                            width: width * 0.66, // ≈ 249
                            child: Text(
                              "Paypal",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: height * 0.018, // ≈ 14
                                fontWeight: FontWeight.w500,
                                height: 1.85, // ≈ 26
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ),
                          Container(
                            width: height * 0.025,
                            height: height * 0.025,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.015),
                    Container(
                      width: width * 0.92,
                      height: height * 0.31, // ≈ 240
                      padding: EdgeInsets.all(width * 0.03),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height * 0.015),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/icon/Credit Card.png",
                                width: height * 0.03,
                                height: height * 0.03,
                              ),
                              SizedBox(width: width * 0.03),
                              Expanded(
                                child: Text(
                                  "Credit Card",
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: height * 0.018,
                                    fontWeight: FontWeight.w500,
                                    height: 1.85,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: height * 0.03,
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.015),
                          Container(
                            width: width * 0.86,
                            height: height * 0.065,
                            padding: EdgeInsets.all(width * 0.03),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(height * 0.015),
                              border:
                                  Border.all(color: const Color(0xFFF0F0F0)),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/images/card.png",
                                  width: height * 0.035,
                                  height: height * 0.035,
                                ),
                                SizedBox(width: width * 0.03),
                                Expanded(
                                  child: Text(
                                    "•••• 7658",
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: height * 0.018,
                                      fontWeight: FontWeight.w500,
                                      height: 1.85,
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: height * 0.025,
                                  height: height * 0.025,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF702F6E),
                                    border: Border.all(
                                        color: const Color(0xFF702F6E)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.015),
                          Container(
                            width: width * 0.86,
                            height: height * 0.065,
                            padding: EdgeInsets.all(width * 0.03),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(height * 0.015),
                              border:
                                  Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/images/visa.png",
                                  width: height * 0.035,
                                  height: height * 0.035,
                                ),
                                SizedBox(width: width * 0.03),
                                Expanded(
                                  child: Text(
                                    "•••• 2322",
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: height * 0.018,
                                      fontWeight: FontWeight.w500,
                                      height: 1.85,
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: height * 0.025,
                                  height: height * 0.025,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFE0E0E0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.015),
                          Container(
                            width: width * 0.86,
                            height: height * 0.062, // ≈ 50
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(height * 0.015),
                              border:
                                  Border.all(color: const Color(0xFF3196F3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: height * 0.025,
                                  color: const Color(0xFF3196F3),
                                ),
                                SizedBox(width: width * 0.02),
                                Text(
                                  "Add new card",
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: height * 0.018,
                                    fontWeight: FontWeight.w500,
                                    height: 1.85,
                                    color: const Color(0xFF3196F3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.015),
                    Container(
                      width: width * 0.92,
                      height: height * 0.065,
                      padding: EdgeInsets.all(width * 0.03),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height * 0.015),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/gpay.png",
                            width: height * 0.035,
                            height: height * 0.035,
                          ),
                          SizedBox(width: width * 0.03),
                          Expanded(
                            child: Text(
                              "Google Pay",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: height * 0.018,
                                fontWeight: FontWeight.w500,
                                height: 1.85,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ),
                          Container(
                            width: height * 0.025,
                            height: height * 0.025,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
      bottomNavigationBar: _bottombar(width: width, height: height),
    );
  }

  Widget _bottombar({
    required width,
    required height,
  }) {
    return Container(
      width: width, // ≈ 393
      height: height * 0.175, // ≈ 140
      padding: EdgeInsets.all(width * 0.05), // ≈ 20
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.90, // ≈ 353
            height: height * 0.035, // ≈ 28
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: width * 0.74, // ≈ 290
                  child: Text(
                    "Total",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.02, // ≈ 16
                      fontWeight: FontWeight.w500, // Medium
                      height: 1.75, // ≈ 28
                      color: const Color(0xFF858585),
                    ),
                  ),
                ),
                SizedBox(
                  width: width * 0.16, // ≈ 63
                  child: Text(
                    "\$245,51",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.02, // ≈ 16
                      fontWeight: FontWeight.w700, // Bold
                      height: 1.75,
                      color: const Color(0xFF232323),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: height * 0.015), // gap 12
          SizedBox(
            width: width * 0.90, // ≈ 353
            height: height * 0.075, // ≈ 60
            child: PrimaryActionButton(
              text: "PayNow",
              onPressed: () {
                DialogHelper.showSuccessDialog(
                  title: "Payment Successfully Processed",
                  description:
                      "Thank you for your purchase! Your payment has been successfully processed. Sit back, relax, and enjoy your new items.",
                  imagePath: "assets/images/success.png",
                  buttonText: "Continue",
                  onPressed: () {
                    Get.back();
                    // Navigate if needed
                    //Get.toNamed(Routes.ADDPROFILE);
                  },
                );
                // payment logic
              },
            ),
          ),
        ],
      ),
    );
  }
}
