// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/helpandsupport_controller.dart';

class HelpandsupportView extends GetView<HelpandsupportController> {
  const HelpandsupportView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Terms & Condition',
              style: TextStyle(
                  fontFamily: 'lato',
                  fontSize: 16,
                  // color: themeTextColor,
                  fontWeight: FontWeight.w600)),
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: pageSurroundingPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image.asset('assets/images/helpandsupport.jpg'),
                ),
                SizedBox(height: 20),
                Text('Help Center',
                    style: TextStyle(
                      fontFamily: 'lato',
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(height: 10),
                Text(
                    'Please get in touch and we will be happy to help you. Get quick customer support by selecting your item',
                    style: TextStyle(
                      fontFamily: 'lato',
                    )),
                SizedBox(height: 10),
                Text('What issues are you facing?',
                    style: TextStyle(
                      fontFamily: 'lato',
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(height: 20),

                GetBuilder<HelpandsupportController>(
                    builder: (controller) => ListView.builder(
                          padding: EdgeInsets.all(0),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.faqs.length,
                          itemBuilder: ((context, index) {
                            return ExpansionPanelList(
                              animationDuration: Duration(milliseconds: 500),
                              elevation: 0,
                              expandedHeaderPadding: EdgeInsets.zero,
                              children: [
                                ExpansionPanel(
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      title: Text(
                                        controller.faqs[index]['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      onTap: () {
                                        controller.toggleExpansion(index);
                                        controller.subfaqs.clear();

                                        controller.subfaqs.addAll(controller
                                            .faqs[index]['faqs_detail']);

                                        if (controller.subfaqs.isEmpty) {
                                          controller.subfaqs
                                              .add({'name': 'no data found'});
                                        }
                                      },
                                    );
                                  },
                                  body: Column(
                                    children: [
                                      // Divider(
                                      //   height: 2,
                                      // ),
                                      Obx(
                                        () => ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: controller.subfaqs.length,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, subindex) {
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      15.0, 10.0, 10.0, 10.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        width: Get.width * 0.8,
                                                        child: Text(
                                                          controller.subfaqs[
                                                                      subindex]
                                                                  ['ques'] ??
                                                              '',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily:
                                                                  "Lato"),
                                                        ),
                                                      ),
                                                      // Text(
                                                      //     controller
                                                      //             .subfaqs[subindex]
                                                      //         ['ans'],
                                                      //     maxLines: 4,
                                                      //     softWrap: true),
                                                      SizedBox(
                                                        width: Get.width * 0.8,
                                                        child: Html(
                                                          onLinkTap: (url,
                                                              attributes,
                                                              element) async {
                                                            if (await canLaunch(
                                                                url!)) {
                                                              await launch(url);
                                                            } else {
                                                              throw 'Could not launch $url';
                                                            }
                                                          },
                                                          data: controller
                                                                  .subfaqs[
                                                              subindex]['ans'],
                                                          style: {
                                                            'html': Style(
                                                                padding:
                                                                    HtmlPaddings
                                                                        .zero), // Apply zero padding to the <html> tag
                                                            'body': Style(
                                                                padding:
                                                                    HtmlPaddings
                                                                        .zero), // Apply zero padding to the <body> tag
                                                          },
                                                        ),
                                                      )
                                                      // Text('data')
                                                    ],
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      Divider(
                                        height: 2,
                                      ),
                                    ],
                                  ),
                                  isExpanded:
                                      controller.expandedindex.value == index,
                                ),
                              ],
                              expansionCallback:
                                  (int panelIndex, bool isExpanded) {
                                controller.toggleExpansion(index);

                                controller.subfaqs.clear();

                                controller.subfaqs.addAll(
                                    controller.faqs[index]['faqs_detail']);

                                if (controller.subfaqs.isEmpty) {
                                  controller.subfaqs
                                      .add({'name': 'no data found'});
                                }
                              },
                            );
                          }),
                        )),

                // SizedBox(
                //   height: 200,
                //   child: ListView.separated(
                //     itemCount: controller.faqs.length,
                //     separatorBuilder: (context, index) {
                //       return SizedBox(
                //         height: 20,
                //       );
                //     },
                //     itemBuilder: (context, index) {
                //       return ListTileTheme(
                //         dense: true,
                //         child: ExpansionTile(
                //             backgroundColor: themegreyColor,
                //             tilePadding: const EdgeInsets.symmetric(
                //                 vertical: 0, horizontal: 10),
                //             childrenPadding: const EdgeInsets.all(0),
                //             title: Text(controller.faqs[index]['name'],
                //                 style: const TextStyle(
                //                     fontFamily: "lato",
                //                     fontWeight: FontWeight.w600)),
                //             children: <Widget>[
                //               SizedBox(
                //                 height: 190,
                //                 child: ListView.builder(
                //                   itemCount: controller
                //                       .faqs[index]['faqs_detail'].length,
                //                   itemBuilder: (context, subindex) {
                //                     return Row(
                //                       crossAxisAlignment:
                //                           CrossAxisAlignment.end,
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.start,
                //                       children: const [
                //                         Padding(
                //                           padding: EdgeInsets.fromLTRB(
                //                               10.0, 0.0, 10.0, 10.0),
                //                           child: Text(
                //                             "No Data found",
                //                             style:
                //                                 TextStyle(fontFamily: "Lato"),
                //                           ),
                //                         )
                //                       ],
                //                     );
                //                   },
                //                 ),
                //               )
                //             ],

                //             ),
                //       );
                //     },
                //   ),
                // ),
                // ListTileTheme(
                //   dense: true,
                //   child: ExpansionTile(
                //       backgroundColor: themegreyColor,
                //       tilePadding: const EdgeInsets.symmetric(
                //           vertical: 0, horizontal: 10),
                //       childrenPadding: const EdgeInsets.all(0),
                //       title: Text('I want to manage my order',
                //           style: const TextStyle(
                //               fontFamily: "lato", fontWeight: FontWeight.w600)),
                //       children: <Widget>[
                //         Row(
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: const [
                //             Padding(
                //               padding:
                //                   EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                //               child: Text(
                //                 "No Data found",
                //                 style: TextStyle(fontFamily: "Lato"),
                //               ),
                //             )
                //           ],
                //         )
                //       ]),
                // ),
                // SizedBox(height: 20),
                // ListTileTheme(
                //   dense: true,
                //   child: ExpansionTile(
                //       backgroundColor: themegreyColor,
                //       tilePadding: const EdgeInsets.symmetric(
                //           vertical: 0, horizontal: 10),
                //       childrenPadding: const EdgeInsets.all(0),
                //       title: Text(
                //           'I did not receive Instant Cashback (Credit/Debit Card)',
                //           style: const TextStyle(
                //               fontFamily: "lato", fontWeight: FontWeight.w600)),
                //       children: <Widget>[
                //         Row(
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: const [
                //             Padding(
                //               padding:
                //                   EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                //               child: Text(
                //                 "No Data found",
                //                 style: TextStyle(fontFamily: "Lato"),
                //               ),
                //             )
                //           ],
                //         )
                //       ]),
                // ),
                // SizedBox(height: 20),
                // ListTileTheme(
                //   dense: true,
                //   child: ExpansionTile(
                //       backgroundColor: themegreyColor,
                //       tilePadding: const EdgeInsets.symmetric(
                //           vertical: 0, horizontal: 10),
                //       childrenPadding: const EdgeInsets.all(0),
                //       title: Text('I want help with other issues',
                //           style: const TextStyle(
                //               fontFamily: "lato", fontWeight: FontWeight.w600)),
                //       children: <Widget>[
                //         Row(
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: const [
                //             Padding(
                //               padding:
                //                   EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                //               child: Text(
                //                 "No Data found",
                //                 style: TextStyle(fontFamily: "Lato"),
                //               ),
                //             )
                //           ],
                //         )
                //       ]),
                // ),
                // SizedBox(height: 20),
                // ListTileTheme(
                //   dense: true,
                //   child: ExpansionTile(
                //       backgroundColor: themegreyColor,
                //       tilePadding: const EdgeInsets.symmetric(
                //           vertical: 0, horizontal: 10),
                //       childrenPadding: const EdgeInsets.all(0),
                //       title: Text('I am unable to pay using wallet',
                //           style: const TextStyle(
                //               fontFamily: "lato", fontWeight: FontWeight.w600)),
                //       children: <Widget>[
                //         Row(
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: const [
                //             Padding(
                //               padding:
                //                   EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                //               child: Text(
                //                 "No Data found",
                //                 style: TextStyle(fontFamily: "Lato"),
                //               ),
                //             )
                //           ],
                //         )
                //       ]),
                // ),
                // SizedBox(height: 20),
                // ListTileTheme(
                //   dense: true,
                //   child: ExpansionTile(
                //       backgroundColor: themegreyColor,
                //       tilePadding: const EdgeInsets.symmetric(
                //           vertical: 0, horizontal: 10),
                //       childrenPadding: const EdgeInsets.all(0),
                //       title: Text(
                //           'I want to unsubscribe from promotional emails and SMS',
                //           style: const TextStyle(
                //               fontFamily: "lato", fontWeight: FontWeight.w600)),
                //       children: <Widget>[
                //         Row(
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: const [
                //             Padding(
                //               padding:
                //                   EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                //               child: Text(
                //                 "No Data found",
                //                 style: TextStyle(fontFamily: "Lato"),
                //               ),
                //             )
                //           ],
                //         )
                //       ]),
                // ),
                // SizedBox(height: 20),
                // ListTileTheme(
                //   dense: true,
                //   child: ExpansionTile(
                //       backgroundColor: themegreyColor,
                //       tilePadding: const EdgeInsets.symmetric(
                //           vertical: 0, horizontal: 10),
                //       childrenPadding: const EdgeInsets.all(0),
                //       title: Text('I want help with returns & refunds',
                //           style: const TextStyle(
                //               fontFamily: "lato", fontWeight: FontWeight.w600)),
                //       children: <Widget>[
                //         Row(
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: const [
                //             Padding(
                //               padding:
                //                   EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                //               child: Text(
                //                 "No Data found",
                //                 style: TextStyle(fontFamily: "Lato"),
                //               ),
                //             )
                //           ],
                //         )
                //       ]),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
