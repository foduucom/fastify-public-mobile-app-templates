import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';

class SupportTicketController extends GetxController with BaseController {
  static const int _pageSize = 20;

  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var hasNext = false.obs;
  var supportTickets = [].obs;
  final scrollController = ScrollController();
  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.hasClients &&
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200) {
        loadMoreTickets();
      }
    });
    getSupportTickets();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// Parses `{tickets: [...], pagination: {...}}`, tolerating a bare list.
  List _extractTickets(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      if (response['tickets'] is List) return response['tickets'];
      if (response['data'] is List) return response['data'];
    }
    return const [];
  }

  bool _extractHasNext(dynamic response, int received) {
    if (response is Map && response['pagination'] is Map) {
      return response['pagination']['has_next'] == true;
    }
    return received >= _pageSize;
  }

  Future<void> getSupportTickets() async {
    try {
      isLoading.value = true;
      _page = 1;
      var response = await BasicProvider('customer/support-tickets')
          .getRequest(queryParams: {
        'page': '$_page',
        'limit': '$_pageSize',
      }).catchError(handleError);

      isLoading.value = false;
      if (response != null) {
        final tickets = _extractTickets(response);
        supportTickets.assignAll(tickets);
        hasNext.value = _extractHasNext(response, tickets.length);
      }
    } catch (e) {
      isLoading.value = false;
      print('error on fetching support tickets $e');
    }
  }

  Future<void> loadMoreTickets() async {
    if (isLoading.value || isLoadMore.value || !hasNext.value) return;
    try {
      isLoadMore.value = true;
      var response = await BasicProvider('customer/support-tickets')
          .getRequest(queryParams: {
        'page': '${_page + 1}',
        'limit': '$_pageSize',
      }).catchError(handleError);
      if (response != null) {
        _page++;
        final tickets = _extractTickets(response);
        supportTickets.addAll(tickets);
        hasNext.value = _extractHasNext(response, tickets.length);
      }
    } catch (e) {
      print('error on loading more support tickets $e');
    } finally {
      isLoadMore.value = false;
    }
  }

  /// Backend ticket types: support | billing | technical | general.
  String _mapTicketType(String uiValue) {
    switch (uiValue.toLowerCase()) {
      case 'billing':
        return 'billing';
      case 'technical':
        return 'technical';
      case 'support':
        return 'support';
      default:
        return 'general';
    }
  }

  static String mimeTypeFor(String fileName) {
    switch (fileName.split('.').last.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'image/jpeg';
    }
  }

  Future<bool> createSupportTicket({
    required String subject,
    required String message,
    required String priority,
    required String ticketType,
    List<File>? files,
  }) async {
    try {
      isLoading.value = true;

      final Map<String, dynamic> formMap = {
        'subject': subject,
        'message': message,
        'ticket_type': _mapTicketType(ticketType),
        'priority': priority.toLowerCase(),
      };

      // The backend accepts a single attachment per ticket.
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final name = file.path.split('/').last;
        formMap['attachment'] = MultipartFile(
          file,
          filename: name,
          contentType: mimeTypeFor(name),
        );
      }

      var response = await BasicProvider('customer/support-tickets')
          .postRequest(FormData(formMap))
          .catchError(handleError);
      isLoading.value = false;
      if (response != null) {
        await getSupportTickets();
        return true;
      }
    } catch (e) {
      isLoading.value = false;
      print('error creating support ticket $e');
    }
    return false;
  }

  /// The API has no delete; tickets are closed instead.
  Future<bool> closeSupportTicket(String id, int index) async {
    try {
      var response = await BasicProvider('customer/support-tickets/$id/close')
          .postRequest({}).catchError(handleError);
      if (response != null) {
        if (index >= 0 && index < supportTickets.length) {
          final ticket = supportTickets[index];
          if (ticket is Map) {
            ticket['status'] = 'closed';
            ticket['can_reply'] = false;
            supportTickets[index] = ticket;
            supportTickets.refresh();
          }
        }
        return true;
      }
    } catch (e) {
      print('error closing support ticket $e');
    }
    return false;
  }
}
