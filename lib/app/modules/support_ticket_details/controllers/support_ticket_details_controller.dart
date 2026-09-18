import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class SupportTicketDetailsController extends GetxController
    with BaseController {
  late String supportTicketId;
  final TextEditingController messageController = TextEditingController();

  var supportTicketDetails = {}.obs;
  var chatMessages = [].obs;
  var isChatLoading = false.obs;
  var isMessageSendLoading = false.obs;
  var selectedFiles = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    supportTicketId = (arguments != null ? arguments['id'] : '').toString();
    if (supportTicketId.isNotEmpty) {
      fetchChatsMessages(supportTicketId);
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  Future<void> fetchChatsMessages(String id) async {
    try {
      isChatLoading.value = true;
      var response = await BasicProvider("customer/support-tickets/$id")
          .getRequest()
          .catchError(handleError);

      if (response == null || response is! Map) return;

      Map<String, dynamic> ticket = {};
      List replies = [];

      final rawTicket = response['ticket'] ?? response['data'];
      if (rawTicket is Map) {
        if (rawTicket['ticket'] is Map) {
          ticket = Map<String, dynamic>.from(rawTicket['ticket']);
        } else {
          ticket = Map<String, dynamic>.from(rawTicket);
        }
      }

      final rawReplies = response['replies'] ?? (response['data'] is Map ? response['data']['replies'] : null);
      if (rawReplies is List) {
        replies = rawReplies;
      }

      supportTicketDetails.value = ticket;

      final List<dynamic> newMessages = [
        if (ticket.isNotEmpty)
          {
            'is_customer': true,
            'message': ticket['message'],
            'created_at': ticket['created_at'],
            'attachments': _wrapAttachment(ticket['attachment']),
          },
        ...replies.whereType<Map>().map((reply) {
          final map = Map<String, dynamic>.from(reply);
          map['attachments'] = _wrapAttachment(map['attachment']);
          return map;
        }),
      ];

      // Detail view renders reverse=true (newest first), so keep newest-last order reversed.
      chatMessages.value = newMessages.reversed.toList();
    } catch (e) {
      debugPrint('fetchChatsMessages error: $e');
      HelperFunctions().showSnackBarError('Failed to load ticket thread');
    } finally {
      isChatLoading.value = false;
    }
  }

  Future<void> sendMessagesWithFiles({
    required String message,
    List<File> files = const [],
  }) async {
    if (message.trim().isEmpty && files.isEmpty) return;
    if (supportTicketDetails['can_reply'] == false) {
      HelperFunctions().showSnackBarError('This ticket is closed');
      return;
    }
    try {
      isMessageSendLoading.value = true;

      final Map<String, dynamic> formMap = {'message': message.trim()};

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

        formMap['image'] =
            MultipartFile(file, filename: name, contentType: mimeType);
      }

      var form = FormData(formMap);
      var response =
          await BasicProvider("customer/support-tickets/$supportTicketId/replies")
              .postRequest(form)
              .catchError(handleError);

      if (response == null) return;

      selectedFiles.clear();
      messageController.clear();
      await fetchChatsMessages(supportTicketId);
    } catch (e) {
      debugPrint('sendMessagesWithFiles error: $e');
      HelperFunctions().showSnackBarError('Failed to send reply');
    } finally {
      isMessageSendLoading.value = false;
    }
  }

  void removeSelectedFile(File file) {
    selectedFiles.remove(file);
  }

  List<Map<String, dynamic>> _wrapAttachment(dynamic attachment) {
    if (attachment == null || attachment is! Map) return [];
    final map = Map<String, dynamic>.from(attachment);
    final resolved = map['download_url'] ?? map['url'] ?? map['file_url'];
    return [
      {...map, if (resolved != null) 'download_url': resolved}
    ];
  }
}
