// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import '../../constants/constants.dart';

// class AppFormTextField extends StatelessWidget {
//   const AppFormTextField({
//     Key? key,
//     required this.fieldHintText,
//     this.hintText = '',
//     required this.controller,
//     required this.validationmsg,
//     required this.onsaved,
//     this.validCheck,
//     this.keyType = TextInputType.text,
//     this.isTextInput = false,
//     this.obsecure = false,
//     this.maxLine = 1,
//     this.textlength = 50,
//   }) : super(key: key);

//   final String fieldHintText;
//   final String hintText;
//   final TextEditingController controller;
//   final String validationmsg;
//   final Function(String?)? onsaved;
//   final String? Function(String?)? validCheck;
//   final bool obsecure;
//   final TextInputType keyType;
//   final int maxLine;
//   final int textlength;
//   final bool isTextInput;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(height: 17),
//         TextFormField(
//           maxLines: maxLine == 0 ? null : maxLine,
//           onSaved: onsaved,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           // cursorColor: themeSecondrytext,
//           keyboardType: keyType,
//           inputFormatters: isTextInput
//               ? [
//                   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
//                 ]
//               : null,
//           controller: controller,
//           obscureText: obsecure,
//           validator: validCheck,
//           decoration: InputDecoration(
//               hintText: hintText,
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               contentPadding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
//               labelText: fieldHintText,
//               labelStyle: const TextStyle(fontFamily: 'Lato')),
//         ),
//       ],
//     );
//   }
// }
