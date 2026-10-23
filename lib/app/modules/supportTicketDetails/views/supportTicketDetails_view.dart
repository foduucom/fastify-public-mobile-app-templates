import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:zouhi/app/modules/supportTicketDetails/controller/supportTicketDetails_controller.dart';
import 'package:zouhi/app/modules/supportTicketDetails/widgets/chat_attachment_widget.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class SupportTicketDetailsView extends GetView<SupportTicketDetailsController> {
  const SupportTicketDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Obx(() {
            var details = controller.supportTicketDetails;
            var ticketNo =
                details['ticket_id'] ?? details['id'] ?? details['_id'];
            if (ticketNo != null && ticketNo.toString().isNotEmpty) {
              var displayNo = ticketNo.toString();
              if (displayNo.length > 8 &&
                  (details['ticket_id'] == null ||
                      details['ticket_id'].toString().isEmpty)) {
                displayNo = displayNo.substring(0, 6);
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#$displayNo',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: context.themeTextColor),
                  ),
                  Text(
                    '${details['subject'] ?? ''}',
                    style: TextStyle(fontSize: 14, color: context.themeSecondrytext),
                  )
                ],
              );
            } else {
              return Text(
                'Support Ticket',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.themeTextColor),
              );
            }
          }),
          actions: [
            Obx(
              () => HelperFunctions.buildStatusChip(
                  controller.supportTicketDetails['status'] ?? ''),
            ),
            const SizedBox(width: 6),
            Obx(
              () => HelperFunctions.buildStatusChip(
                  controller.supportTicketDetails['priority'] ?? ''),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Column(children: [
          const SizedBox(height: 12),
          Obx(() => controller.isChatLoading.isTrue &&
                  controller.chatMessages.isNotEmpty
              ? HelperFunctions().loadingIndicator()
              : Container()),
          const SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.chatMessages.length,
                    reverse: true, // Changed to true to show latest at bottom
                    itemBuilder: (context, index) {
                      return _buildMessageContainer(
                          context,
                          controller.chatMessages[index],
                          index,
                          controller.chatMessages.length);
                    },
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final canReply = controller.supportTicketDetails['can_reply'] != false &&
                controller.supportTicketDetails['status']
                        ?.toString()
                        .toLowerCase() !=
                    'closed';
            if (!canReply) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'This ticket is closed. You can no longer reply.',
                  style: TextStyle(
                      fontSize: 13, color: context.themeSecondrytext),
                ),
              );
            }
            return _buildInputArea(context, controller);
          })
        ]),
      ),
    );
  }

  // Modified getReadableDate to return a map with display date and formatted time
  Map<String, String> getFormattedDateTime(String messageDate) {
    final now = DateTime.now();
    final messageDateTime = DateTime.parse(messageDate).toLocal();

    String displayDate;
    if (now.year == messageDateTime.year &&
        now.month == messageDateTime.month &&
        now.day == messageDateTime.day) {
      displayDate = "Today";
    } else if (now.year == messageDateTime.year &&
        now.month == messageDateTime.month &&
        now.day - 1 == messageDateTime.day) {
      displayDate = "Yesterday";
    } else {
      displayDate = DateFormat('MMM d, yyyy').format(messageDateTime);
    }

    final formattedTime = DateFormat('h:mm a')
        .format(messageDateTime); // 12-hour format with AM/PM

    return {
      'displayDate': displayDate,
      'formattedTime': formattedTime,
    };
  }

  Widget _buildMessageContainer(
    BuildContext context,
    var messageData,
    int index,
    int totalMessages,
  ) {
    // Correctly get the current message and the previous one for date comparison
    final currentMessage = controller.chatMessages[index];
    final previousMessageIndex = index +
        1; // Corrected to get the message *before* the current one in a reversed list
    final previousMessage = previousMessageIndex < totalMessages
        ? controller.chatMessages[previousMessageIndex]
        : null;

    final currentMessageDateTime = getFormattedDateTime(
        currentMessage['created_at'] ?? DateTime.now().toString());
    final previousMessageDateTime = previousMessage != null
        ? getFormattedDateTime(
            previousMessage['created_at'] ?? DateTime.now().toString())
        : null;

    // Determine if we should show the date label
    bool shouldShowDateLabel = previousMessage == null ||
        currentMessageDateTime['displayDate'] !=
            previousMessageDateTime?['displayDate'];

    return Column(
      children: [
        if (shouldShowDateLabel)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:
                    themePrimaryColor, // Assuming themePrimaryColor is defined
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentMessageDateTime['displayDate']!,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        Builder(
          builder: (context) {
            final isCustomer = currentMessage['user'] == 'customer';
            final bubbleMaxWidth = MediaQuery.of(context).size.width * 0.78;
            final messageText = currentMessage['message']?.toString() ?? '';

            if (isCustomer) {
              return Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 140,
                      maxWidth: bubbleMaxWidth,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? Colors.blueGrey.withOpacity(0.2)
                          : const Color.fromRGBO(192, 220, 238, 0.243),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ChatAttachmentWidget(
                          messageData: currentMessage,
                          isSender: true,
                        ),
                        if (messageText.trim().isNotEmpty)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              messageText,
                              style: TextStyle(
                                fontSize: 15,
                                color: context.themeTextColor,
                              ),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          currentMessageDateTime['formattedTime']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 140,
                      maxWidth: bubbleMaxWidth,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? Colors.grey.withOpacity(0.15)
                          : const Color.fromRGBO(218, 237, 250, 0.247),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChatAttachmentWidget(
                          messageData: currentMessage,
                          isSender: false,
                        ),
                        if (messageText.trim().isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: HtmlWidget(messageText),
                          ),
                        const SizedBox(height: 2),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            currentMessageDateTime['formattedTime']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }


  void _showAttachmentPicker(
      BuildContext context, SupportTicketDetailsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Share Attachment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.themeTextColor,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPickerOption(
                      context: context,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFFE91E63),
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickImageFromCamera();
                      },
                    ),
                    _buildPickerOption(
                      context: context,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xFF9C27B0),
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickImageFromGallery();
                      },
                    ),
                    _buildPickerOption(
                      context: context,
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      color: const Color(0xFFFF9800),
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickVideo();
                      },
                    ),
                    _buildPickerOption(
                      context: context,
                      icon: Icons.insert_drive_file_rounded,
                      label: 'Document',
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickDocument();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.themeTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(
      BuildContext context, SupportTicketDetailsController controller) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 10),
      child: Column(
        children: [
          // Selected media preview section (Photos, Videos, PDFs)
          Obx(() {
            if (controller.selectedFiles.isEmpty) {
              return const SizedBox.shrink();
            }
            final file = controller.selectedFiles.first;
            final fileName = file.path.split('/').last;
            final ext = fileName.split('.').last.toLowerCase();
            final isImage =
                ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
            final isVideo =
                ['mp4', 'mov', 'mkv', 'webm', '3gp'].contains(ext);
            final isPdf = ext == 'pdf';

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.themeBorderColor),
              ),
              child: Row(
                children: [
                  if (isImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        height: 48,
                        width: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: isPdf
                            ? const Color(0xFFFFEBEE)
                            : (isVideo
                                ? const Color(0xFFFFF3E0)
                                : const Color(0xFFE3F2FD)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isPdf
                            ? Icons.picture_as_pdf_rounded
                            : (isVideo
                                ? Icons.videocam_rounded
                                : Icons.description_rounded),
                        color: isPdf
                            ? const Color(0xFFE53935)
                            : (isVideo
                                ? const Color(0xFFFF9800)
                                : const Color(0xFF1E88E5)),
                        size: 26,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.themeTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isImage
                              ? 'Photo ready to send'
                              : (isVideo
                                  ? 'Video ready to send'
                                  : (isPdf
                                      ? 'PDF document ready to send'
                                      : 'Document ready to send')),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.themeSecondrytext,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.selectedFiles.clear();
                    },
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Message input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.themeWhiteColor,
                    border: Border.all(color: context.themeBorderColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.messageController,
                          style: TextStyle(color: context.themeTextColor),
                          onChanged: (data) {
                            controller.messageText.value = data;
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: 'Write here ...',
                            hintStyle: TextStyle(
                              color: context.themeSecondrytext,
                              fontFamily: 'latto',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () => IconButton(
                          alignment: Alignment.center,
                          onPressed: () {
                            if (controller.selectedFiles.isNotEmpty) {
                              controller.selectedFiles.clear();
                            } else {
                              _showAttachmentPicker(context, controller);
                            }
                          },
                          icon: Icon(
                            controller.selectedFiles.isNotEmpty
                                ? Icons.remove_circle_outline_rounded
                                : Icons.attach_file_rounded,
                            color: controller.selectedFiles.isNotEmpty
                                ? Colors.red
                                : themePrimaryColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () {
                  final canSend =
                      (controller.messageText.value.trim().isNotEmpty ||
                              controller.selectedFiles.isNotEmpty) &&
                          !controller.isMessageSendLoading.value;

                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        if (canSend) {
                          controller.sendMessagesWithFiles(
                            message: controller.messageController.text,
                            files: controller.selectedFiles,
                          );
                          HelperFunctions().closeKeyboard(context);
                        }
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: canSend ? themePrimaryColor : themeBorderColor,
                          shape: BoxShape.circle,
                        ),
                        child: controller.isMessageSendLoading.value
                            ? HelperFunctions().loadingIndicator()
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
