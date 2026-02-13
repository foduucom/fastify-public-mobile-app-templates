// import 'package:flutter/material.dart';
// import 'package:foduu_ecommerce/components/drawerList.dart';
// import 'package:foduu_ecommerce/constants/constants.dart';
// import 'package:get/get.dart';

// class SideNavigationDrawer extends StatelessWidget {
//   const SideNavigationDrawer({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           SizedBox(
//             height: 80,
//             child: DrawerHeader(
//               padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
//               decoration: BoxDecoration(
//                   // color: themeColor.withOpacity(0.25),
//                   ),
//               child: ListTile(
//                 leading:
//                     ClipOval(child: Image.asset('assets/images/rectangle.png')),
//                 title: const Text('Hello, Paige Turner',
//                     style: TextStyle(
//                         fontFamily: 'Lato', fontWeight: FontWeight.w600)),
//                 trailing: const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 17,
//                   // color: themeTextColor,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.9,
//             child: ListView(
//               children: [
//                 drawerList(
//                   icon: 'assets/icon/homicon.svg',
//                   title: 'Home',
//                   subtitle: 'Offers, Top Deals, Top Brands',
//                   pressevent: () {},
//                 ),
//                 drawerList(
//                   icon: 'assets/icon/drawricon1.svg',
//                   title: 'Shop by Category',
//                   subtitle: 'Men, Women, Kids, Beauty..',
//                   pressevent: () {},
//                 ),
//                 drawerList(
//                   icon: 'assets/icon/drawricon2.svg',
//                   title: 'Orders',
//                   subtitle: 'Ongoing Orders, Recent Orders..',
//                   pressevent: () {},
//                 ),
//                 drawerList(
//                   icon: 'assets/icon/drawricon3.svg',
//                   title: 'Your Wishlist',
//                   subtitle: 'Your Save Products',
//                   pressevent: () {},
//                 ),
//                 drawerList(
//                   icon: 'assets/icon/drawricon7.svg',
//                   title: 'Your Account',
//                   subtitle: 'Profile, Settings, Saved Cards...',
//                   pressevent: () {
//                     // Get.to(const HelpandsupportView());
//                   },
//                 ),
//                 drawerList(
//                   icon: 'assets/icon/drawricon5.svg',
//                   title: 'Notification',
//                   subtitle: 'Offers, Order tracking messages..',
//                   pressevent: () {
//                     // Get.to(NotificationView());
//                   },
//                 ),
//                 drawerList(
//                   icon: 'assets/icon/drawricon6.svg',
//                   title: 'Settings',
//                   subtitle: 'App settings, Dark mode',
//                   pressevent: () {},
//                 ),
//                 drawerList(
//                   icon: 'assets/icon/drawricon.svg',
//                   title: 'About us',
//                   subtitle: 'About Multikart',
//                   pressevent: () {
//                     // Get.to(const TermsandconditionView());
//                   },
//                 ),
//                 drawerList(
//                   icon: 'assets/icon/fill1.svg',
//                   title: 'Help/Customer Care',
//                   subtitle: 'Customer Support, FAQs',
//                   pressevent: () {},
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
