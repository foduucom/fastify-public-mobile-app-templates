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
  final loadError = false.obs;

  @override
  void onInit() {
    super.onInit();
    getSupportTickets();
  }

  Future<void> getSupportTickets() async {
    try {
      isLoading.value = true;
      loadError.value = false;
      var response = await BasicProvider("customer/support-tickets").getRequest(
          queryParams: {'page': 1, 'limit': 10}).catchError(handleError);
      final rawTickets = _extractTickets(response);
      if (rawTickets == null || _writeFailed(response)) {
        loadError.value = true;
        return;
      }

      Map<String, dynamic> rawPagination = {};
      if (response is Map && response['pagination'] is Map) {
        rawPagination = Map<String, dynamic>.from(response['pagination']);
      }
      supportTickets
        ..clear()
        ..addAll(rawTickets);
      pagination.value = rawPagination;
    } catch (e) {
      loadError.value = true;
      debugPrint('getSupportTickets error: $e');
      HelperFunctions().showSnackBarError('Failed to load support tickets');
    } finally {
      isLoading.value = false;
    }
  }

  List<dynamic>? _extractTickets(dynamic response) {
    if (response is List) return response;
    if (response is! Map) return null;
    for (final key in ['tickets', 'data', 'docs', 'results', 'items']) {
      if (!response.containsKey(key)) continue;
      final value = response[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractTickets(value);
        if (nested != null) return nested;
      }
    }
    return null;
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

      if (_writeFailed(response)) {
        HelperFunctions().showSnackBarError(
            'Could not create the support ticket. Please try again.');
        return false;
      }

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

  Future<bool> closeSupportTicket(String id) async {
    if (id.trim().isEmpty || id == 'null') {
      HelperFunctions()
          .showSnackBarError('This ticket is missing its reference ID.');
      return false;
    }
    try {
      final response = await BasicProvider("customer/support-tickets/$id/close")
          .postRequest({}).catchError(handleError);
      if (response == null ||
          (response is Map &&
              (response['success'] == false ||
                  response['status'] == false ||
                  const {
                    'error',
                    'failed',
                    'failure'
                  }.contains(response['status']?.toString().toLowerCase())))) {
        throw Exception('Ticket closure was not confirmed');
      }

      final actualIndex = supportTickets.indexWhere((item) =>
          item is Map && (item['id'] ?? item['_id']).toString() == id);
      if (actualIndex >= 0 && actualIndex < supportTickets.length) {
        final ticket = Map<String, dynamic>.from(supportTickets[actualIndex]);
        ticket['status'] = 'closed';
        ticket['can_reply'] = false;
        supportTickets[actualIndex] = ticket;
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

  bool _writeFailed(dynamic response) {
    if (response == null) return true;
    if (response is! Map) return false;
    final status = response['status']?.toString().toLowerCase();
    return response['success'] == false ||
        status == 'false' ||
        status == 'error' ||
        status == 'failed' ||
        status == 'failure' ||
        status == '409';
  }
}
