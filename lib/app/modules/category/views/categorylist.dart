import 'package:get/get.dart';

class Employee {
  Employee({
    this.body,
    this.header,
    this.isExpanded,
  });

  String? body;
  String? header;
  RxBool? isExpanded;
}