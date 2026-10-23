import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';

class SupportTicketDetailsController extends GetxController
    with BaseController {
  var messageSendLoading = false.obs;
  var messageText = ''.obs;
  var messageController = TextEditingController();
  var chatMessages = [].obs;
  var supportTicketDetails = {}.obs;
  var isChatLoading = false.obs;
  var isMessageSendLoading = false.obs;
  var supportTicketId = '';
  var selectedFiles = <File>[].obs;

  var uploadedGalleryId = [].obs;

  var courseId = '';
  var teacherId = '';
  var customer = '';
  var isNew = false;
  var courseName = ''.obs;

  @override
  void onInit() {
    var arguments = Get.arguments;
    supportTicketId = (arguments is Map ? arguments['id'] : null)?.toString() ?? '';

    fetchChatsMessages(id: supportTicketId);
    super.onInit();
  }

  Future<void> fetchChatsMessages({required String id}) async {
    try {
      isChatLoading.value = true;
      var response = await BasicProvider(
        'customer/support-tickets/$id',
      ).getRequest().catchError(handleError);
      isChatLoading.value = false;
      if (response != null && response is Map) {
        supportTicketDetails.clear();
        chatMessages.clear();

        var ticket = response['ticket'];
        if (ticket != null && ticket is Map) {
          supportTicketDetails.assignAll(Map<String, dynamic>.from(ticket));
        } else {
          supportTicketDetails.assignAll(Map<String, dynamic>.from(response));
        }

        var messagesList = <Map<String, dynamic>>[];

        var replies = response['replies'];
        if (replies != null && replies is List) {
          for (var reply in replies) {
            if (reply is Map) {
              // attachment is `{id, name, mime_type, url}`; getImage resolves
              // the Map's `url`, so it is passed through as-is.
              var replyGallery = <dynamic>[];
              if (reply['attachment'] is Map) {
                replyGallery.add(reply['attachment']);
              }
              final isCustomer = reply['is_customer'] == true ||
                  reply['sender_type'] == 'customer';
              messagesList.add({
                ...Map<String, dynamic>.from(reply),
                'user': isCustomer ? 'customer' : 'owner',
                'customer': isCustomer ? (reply['sender_id'] ?? true) : null,
                'gallery': replyGallery,
              });
            }
          }

          var reversedReplies = List.from(messagesList.reversed);

          // Add the ticket's initial message as the oldest message at the top
          var resolvedTicket = ticket is Map ? ticket : response;
          if (resolvedTicket != null) {
            var initialMessageText = resolvedTicket['message']?.toString();
            if (initialMessageText != null && initialMessageText.isNotEmpty) {
              var ticketGallery = <dynamic>[];
              if (resolvedTicket['attachment'] is Map) {
                ticketGallery.add(resolvedTicket['attachment']);
              }
              var initialMessage = {
                'user': 'customer',
                'customer': resolvedTicket['customer'] ?? true,
                'message': initialMessageText,
                'created_at': resolvedTicket['created_at']?.toString() ??
                    DateTime.now().toString(),
                'gallery': ticketGallery,
              };
              reversedReplies.add(initialMessage);
            }
          }

          chatMessages.addAll(reversedReplies);
        } else if (response['message'] != null && response['message'] is List) {
          chatMessages.addAll(List.from(response['message'].reversed));
        }
      }
    } catch (e, stack) {
      print('error on fetching chats $e');
      print(stack);
    }
  }

  static String mimeTypeFor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'svg':
        return 'image/svg+xml';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'mkv':
        return 'video/x-matroska';
      case 'webm':
        return 'video/webm';
      case 'avi':
        return 'video/x-msvideo';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        selectedFiles.value = [File(photo.path)];
      }
    } catch (e) {
      print('Error picking camera image: $e');
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        selectedFiles.value = [File(photo.path)];
      }
    } catch (e) {
      print('Error picking gallery image: $e');
    }
  }

  Future<void> pickVideo() async {
    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final file = File(video.path);
        final sizeInBytes = await file.length();
        if (sizeInBytes > 30 * 1024 * 1024) {
          Fluttertoast.showToast(msg: "Video size must be less than 30MB");
          return;
        }
        selectedFiles.value = [file];
      }
    } catch (e) {
      print('Error picking video: $e');
    }
  }

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final sizeInBytes = await file.length();
        if (sizeInBytes > 25 * 1024 * 1024) {
          Fluttertoast.showToast(msg: "File size must be less than 25MB");
          return;
        }
        selectedFiles.value = [file];
      }
    } catch (e) {
      print('Error picking document: $e');
    }
  }

  Future<void> sendMessagesWithFiles({
    required String message,
    required List<File> files,
  }) async {
    try {
      isMessageSendLoading.value = true;

      final text = message.trim();
      final effectiveMessage = text.isNotEmpty
          ? text
          : (files.isNotEmpty ? files.first.path.split('/').last : '');

      if (effectiveMessage.isEmpty) {
        isMessageSendLoading.value = false;
        return;
      }

      // Construct multipart form data
      final Map<String, dynamic> formMap = {
        'message': effectiveMessage,
      };

      // The backend accepts one attachment per reply.
      if (files.isNotEmpty) {
        final file = files.first;
        final name = file.path.split('/').last;
        formMap['attachment'] = MultipartFile(
          file,
          filename: name,
          contentType: mimeTypeFor(name),
        );
      }

      final formData = FormData(formMap);

      var response = await BasicProvider(
        'customer/support-tickets/$supportTicketId/replies',
      ).postRequest(formData).catchError(handleError);

      print('responsee---- ${response}');
      isMessageSendLoading.value = false;

      if (response != null) {
        selectedFiles.clear();

        fetchChatsMessages(id: supportTicketId);
        messageController.clear();
        messageText.value = '';
      }
    } catch (e) {
      isMessageSendLoading.value = false;
      print("Error sending message: $e");
    }
  }
}
