import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class SupportTicketController extends GetxController with BaseController {
  var isLoading = false.obs;
  var supportTickets = [].obs;
  var pagination = {}.obs;

  @override
  void onInit() {
    super.onInit();
    getSupportTickets();
  }

  Future<void> getSupportTickets() async {
    try {
      isLoading.value = true;
      var response = await BasicProvider("customer/support-tickets")
          .getRequest(queryParams: {'page': 1, 'limit': 10})
          .catchError(handleError);

      List rawTickets = [];
      Map<String, dynamic> rawPagination = {};

      if (response is List) {
        rawTickets = response;
      } else if (response is Map) {
        final ticketsData = response['tickets'] ?? response['data'] ?? response['docs'];
        if (ticketsData is List) {
          rawTickets = ticketsData;
        } else if (ticketsData is Map && ticketsData['tickets'] is List) {
          rawTickets = ticketsData['tickets'];
          if (ticketsData['pagination'] is Map) {
            rawPagination = Map<String, dynamic>.from(ticketsData['pagination']);
          }
        }
        if (response['pagination'] is Map) {
          rawPagination = Map<String, dynamic>.from(response['pagination']);
        }
      }

      supportTickets
        ..clear()
        ..addAll(rawTickets);
      pagination.value = rawPagination;
    } catch (e) {
      debugPrint('getSupportTickets error: $e');
      HelperFunctions().showSnackBarError('Failed to load support tickets');
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
        final file = files.first;
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

        formMap['image'] = MultipartFile(
          file,
          filename: name,
          contentType: mimeType,
        );
      }

      var form = FormData(formMap);
      var response = await BasicProvider("customer/support-tickets")
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

  Future<bool> closeSupportTicket(String id, int index) async {
    try {
      await BasicProvider("customer/support-tickets/$id/close")
          .postRequest({})
          .catchError(handleError);

      if (index >= 0 && index < supportTickets.length) {
        final ticket = Map<String, dynamic>.from(supportTickets[index]);
        ticket['status'] = 'closed';
        ticket['can_reply'] = false;
        supportTickets[index] = ticket;
      }
      HelperFunctions()
          .showSnackBarSuccess('Support ticket closed successfully');
      return true;
    } catch (e) {
      debugPrint('closeSupportTicket error: $e');
      HelperFunctions().showSnackBarError('Failed to close support ticket');
      return false;
    }
  }
}
