// class OrderTrackingCard extends StatelessWidget {
//   final OrderdetailController controller = Get.find<OrderdetailController>();

//   OrderTrackingCard({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final currentStage = controller.getCurrentStage();

//     if (controller.item['payment_status'] == 'unpaid') {
//       return Card(
//         margin: const EdgeInsets.all(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: const [
//               Text('Order Tracking',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//               SizedBox(height: 8),
//               Text(
//                 'Tracking details will be available once payment is done.',
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Card(
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Center(
//               child: Text(
//                 'Order Tracking',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (controller.isordertrackingloading.value)
//               const Center(child: CircularProgressIndicator())
//             else ...[
//               Text(
//                   'Shipment ID: ${controller.item['shipping_detail']?['shipment_id'] ?? '-'}'),
//               const SizedBox(height: 8),
//               if (controller.trackingData?['shipment_status'] != null)
//                 Text(
//                     'Estimated Delivery: ${controller.trackingData!['etd']?.split(' ')[0] ?? '-'}'),
//               const SizedBox(height: 8),
//               Text('Current Status: ${controller.stages[currentStage - 1]}'),
//               const SizedBox(height: 8),
//               // if (controller.trackingData?['track_url'] != null)
//               // TextButton(
//               //   onPressed: () => launchUrl(
//               //       Uri.parse(controller.trackingData!['track_url'])),
//               //   child: const Text('Track Order'),
//               // ),
//               const SizedBox(height: 24),

//               // Vertical Timeline
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: List.generate(
//                   controller.stages.length,
//                   (index) {
//                     final isCompleted = index < currentStage;
//                     return Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Column(
//                           children: [
//                             Container(
//                               width: 16,
//                               height: 16,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: isCompleted ? Colors.blue : Colors.grey,
//                               ),
//                             ),
//                             if (index != controller.stages.length - 1)
//                               Container(
//                                 width: 2,
//                                 height: 40,
//                                 color: index < currentStage - 1
//                                     ? Colors.blue
//                                     : Colors.grey,
//                               ),
//                           ],
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 0),
//                             child: Text(
//                               controller.stages[index],
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: isCompleted
//                                     ? FontWeight.bold
//                                     : FontWeight.normal,
//                                 color: isCompleted ? Colors.blue : Colors.grey,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
