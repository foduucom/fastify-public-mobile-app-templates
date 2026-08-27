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
      var response = await BasicProvider("support-tickets/$id")
          .getRequest()
          .catchError(handleError);

      if (response == null) return;

      final ticket = response is Map ? response : (response['data'] ?? {});
      supportTicketDetails.value = Map<String, dynamic>.from(ticket);

      final List<dynamic> replies = (ticket['replies'] is List)
          ? List<dynamic>.from(ticket['replies'])
          : [];

      final List<dynamic> newMessages = replies.reversed.toList();
      newMessages.add({
        'user': 'customer',
        'message': ticket['message'],
        'created_at': ticket['created_at'],
        'attachments': ticket['attachments'] ?? ticket['gallery'] ?? [],
      });

      chatMessages.value = newMessages;
    } catch (e) {
      debugPrint('fetchChatsMessages error: $e');
    } finally {
      isChatLoading.value = false;
    }
  }

  Future<void> sendMessagesWithFiles({
    required String message,
    List<File> files = const [],
  }) async {
    if (message.trim().isEmpty && files.isEmpty) return;
    try {
      isMessageSendLoading.value = true;

      final Map<String, dynamic> formMap = {'message': message.trim()};

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

          final multipartFile =
              MultipartFile(file, filename: name, contentType: mimeType);
          if (i == 0) formMap['image'] = multipartFile;
          formMap['images[$i]'] = multipartFile;
        }
      }

      var form = FormData(formMap);
      var response =
          await BasicProvider("support-tickets/$supportTicketId/reply")
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
}
