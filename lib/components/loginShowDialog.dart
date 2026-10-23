// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DialogHelper {
//   static void showLoginDialog() {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text(
//           "Login Required",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         content:
//             const Text("You need to log in to add a product to your cart."),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(), // Close the dialog
//             child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back(); // Close the dialog
//               Get.toNamed('/login'); // Navigate to login page
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             child: const Text("Go to Login"),
//           ),
//         ],
//       ),
//     );
//   }
// }
