// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:multicartapp/constants/constants.dart';

// class FoduuDatePicker extends StatelessWidget {
//   const FoduuDatePicker(
//       {Key? key,
//       required this.fieldHintText,
//       required this.controller,
//       this.initialDate})
//       : super(key: key);

//   final String fieldHintText;
//   final TextEditingController controller;
//   final DateTime? initialDate;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: TextFormField(
//         controller: controller,
//         style: const TextStyle(fontSize: 15.0),

//         decoration: InputDecoration(
//           label: fieldHintText,
//           labelStyle: const TextStyle(
//                   color: themeSecondrytext, fontFamily: 'Lato'),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(5),
//             borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(5),
//             borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1),
//           ),
//         ),
//         readOnly: true, //set it true, so that user will not able to edit text
//         onTap: () async {
//           var date = DateTime.now();

//           DateTime? pickedDate = await showDatePicker(
//               context: context,
//               initialDate: initialDate ?? DateTime(date.year - 18),
//               firstDate: DateTime(1950),
//               lastDate: DateTime(date.year - 1));
//           if (pickedDate != null) {
//             //pickedDate output format => 2021-03-10 00:00:00.000
//             // print(pickedDate);
//             String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);
//             controller.text = formattedDate;
//           }
//         },
//       ),
//     );
//   }
// }
