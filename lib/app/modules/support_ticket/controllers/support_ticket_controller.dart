import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class SupportTicketController extends GetxController with BaseController {
  var isLoading = false.obs;
  var supportTickets = [].obs;

  @override
  void onInit() {
    super.onInit();
    getSupportTickets();
  }

  Future<void> getSupportTickets() async {
    try {
      isLoading.value = true;
      var response = await BasicProvider("customer/support-tickets")
          .getRequest()
          .catchError(handleError);

      supportTickets.clear();
      if (response is List) {
        supportTickets.addAll(response);
      } else if (response is Map && response['data'] is List) {
        supportTickets.addAll(response['data']);
      }
    } catch (e) {
      debugPrint('getSupportTickets error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createSupportTicket({
    required String subject,
    required String message,
    required String priority,
    required String ticketType,
    List<File> files = const [],
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        'subject': subject,
        'message': message,
        'ticket_type': ticketType.toLowerCase(),
        'priority': priority.toLowerCase(),
      };

      if (files.isNotEmpty) {
        for (var i = 0; i < files.length; i++) {
          final file = files[i];
          final name = file.path.split('/').last;
          final extension = name.split('.').last.toLowerCase();
          String mimeType = 'image/jpeg';
          if (extension == 'png') {
            mimeType = 'image/png';
          } else if (extension == 'webp') {
            mimeType = 'image/webp';
          } else if (extension == 'gif') {
            mimeType = 'image/gif';
          }

          final multipartFile = MultipartFile(
            file,
            filename: name,
            contentType: mimeType,
          );

          if (i == 0) {
            formMap['image'] = multipartFile;
          }
          formMap['images[$i]'] = multipartFile;
        }
      }

      var form = FormData(formMap);
      var response = await BasicProvider("customer/support-tickets/create")
          .postRequest(form)
          .catchError(handleError);

      if (response == null) return false;

      HelperFunctions()
          .showSnackBarSuccess('Support ticket created successfully');
      await getSupportTickets();
      return true;
    } catch (e) {
      debugPrint('createSupportTicket error: $e');
      HelperFunctions().showSnackBarError('Failed to create support ticket');
      return false;
    }
  }

  Future<bool> deleteSupportTicket(String id, int index) async {
    try {
      await BasicProvider("customer/support-tickets/$id")
          .deleteRequest()
          .catchError(handleError);
      if (index >= 0 && index < supportTickets.length) {
        supportTickets.removeAt(index);
      }
      HelperFunctions()
          .showSnackBarSuccess('Support ticket deleted successfully');
      return true;
    } catch (e) {
      debugPrint('deleteSupportTicket error: $e');
      HelperFunctions().showSnackBarError('Failed to delete support ticket');
      return false;
    }
  }
}
