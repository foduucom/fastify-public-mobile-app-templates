import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

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

  /// Resolves any relative or absolute URL to a fully qualified URL
  static String resolveAttachmentUrl(dynamic attachment) {
    if (attachment == null) return '';
    if (attachment is String) {
      final str = attachment.trim();
      if (str.isEmpty) return '';
      if (str.startsWith('http://') || str.startsWith('https://')) return str;
      if (str.startsWith('/images/')) return "\$url\${str.substring(1)}";
      if (str.startsWith('images/')) return "\$url\$str";
      if (str.startsWith('/')) return "\$url\${str.substring(1)}";
      return "\$assetURL\$str";
    }
    if (attachment is Map) {
      final raw = attachment['url'] ??
          attachment['download_url'] ??
          attachment['downloadUrl'] ??
          attachment['filePath'] ??
          attachment['filepath'] ??
          attachment['filename'];
      if (raw != null && raw.toString().trim().isNotEmpty) {
        return resolveAttachmentUrl(raw.toString().trim());
      }
    }
    return '';
  }

  /// Classifies attachment media type by mime_type or file extension
  static String detectMediaType(dynamic attachment) {
    String mime = '';
    String name = '';
    String urlStr = '';

    if (attachment is Map) {
      mime = (attachment['mime_type'] ?? '').toString().toLowerCase();
      name = (attachment['name'] ?? '').toString().toLowerCase();
      urlStr = (attachment['url'] ?? '').toString().toLowerCase();
    } else if (attachment is String) {
      urlStr = attachment.toLowerCase();
      name = attachment.split('/').last.toLowerCase();
    }

    if (mime.startsWith('image/') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif') ||
        urlStr.endsWith('.jpg') ||
        urlStr.endsWith('.jpeg') ||
        urlStr.endsWith('.png') ||
        urlStr.endsWith('.webp')) {
      return 'image';
    }

    if (mime.startsWith('video/') ||
        name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.mkv') ||
        name.endsWith('.webm') ||
        name.endsWith('.3gp') ||
        urlStr.endsWith('.mp4') ||
        urlStr.endsWith('.mov') ||
        urlStr.endsWith('.mkv') ||
        urlStr.endsWith('.webm')) {
      return 'video';
    }

    if (mime.contains('pdf') ||
        mime.contains('document') ||
        mime.contains('word') ||
        mime.contains('sheet') ||
        name.endsWith('.pdf') ||
        name.endsWith('.doc') ||
        name.endsWith('.docx') ||
        name.endsWith('.xls') ||
        name.endsWith('.xlsx') ||
        name.endsWith('.txt') ||
        urlStr.endsWith('.pdf')) {
      return 'document';
    }

    return 'other';
  }

  static String getAttachmentName(dynamic attachment) {
    if (attachment is Map) {
      final name = attachment['name']?.toString();
      if (name != null && name.trim().isNotEmpty) return name;
      final urlStr = attachment['url']?.toString();
      if (urlStr != null && urlStr.trim().isNotEmpty) {
        return urlStr.split('/').last;
      }
    } else if (attachment is String) {
      return attachment.split('/').last;
    }
    return 'attachment';
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
      debugPrint('Error picking camera image: $e');
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
      debugPrint('Error picking gallery image: $e');
    }
  }

  Future<void> pickVideoFromGallery() async {
    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final file = File(video.path);
        final size = await file.length();
        if (size > 30 * 1024 * 1024) {
          HelperFunctions().showSnackBarError('Video size must be less than 30MB');
          return;
        }
        selectedFiles.value = [file];
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
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
        final size = await file.length();
        if (size > 25 * 1024 * 1024) {
          HelperFunctions().showSnackBarError('File size must be less than 25MB');
          return;
        }
        selectedFiles.value = [file];
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
    }
  }

  Future<void> fetchChatsMessages(String id) async {
    try {
      isChatLoading.value = true;
      var response = await BasicProvider("customer/support-tickets/\$id")
          .getRequest()
          .catchError(handleError);

      if (response == null || response is! Map) return;

      Map<String, dynamic> ticket = {};
      List replies = [];

      final rawTicket = response['ticket'] ?? (response['data'] is Map ? response['data']['ticket'] : null) ?? response['data'];
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
            'attachment': ticket['attachment'],
            'attachments': _wrapAttachment(ticket['attachment']),
          },
        ...replies.whereType<Map>().map((reply) {
          final map = Map<String, dynamic>.from(reply);
          final isCustomer = reply['is_customer'] == true ||
              reply['sender_type'] == 'customer';
          map['is_customer'] = isCustomer;
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
    final text = message.trim();
    if (text.isEmpty && files.isEmpty) return;
    if (supportTicketDetails['can_reply'] == false) {
      HelperFunctions().showSnackBarError('This ticket is closed');
      return;
    }
    try {
      isMessageSendLoading.value = true;

      final Map<String, dynamic> formMap = {
        'message': text.isNotEmpty ? text : (files.isNotEmpty ? files.first.path.split('/').last : ''),
      };

      if (files.isNotEmpty) {
        final file = files.first;
        final name = file.path.split('/').last;
        final mimeType = mimeTypeFor(name);

        final multipart = MultipartFile(file, filename: name, contentType: mimeType);
        formMap['attachment'] = multipart;
        formMap['image'] = multipart;
      }

      var form = FormData(formMap);
      var response =
          await BasicProvider("customer/support-tickets/\$supportTicketId/replies")
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
    final resolved = resolveAttachmentUrl(map);
    return [
      {...map, if (resolved.isNotEmpty) 'resolved_url': resolved}
    ];
  }
}
