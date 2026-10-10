import '../widgets/chat_attachment_widget.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' hide ImageSource;
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/support_ticket_status.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/support_ticket_details_controller.dart';

class SupportTicketDetailsView extends GetView<SupportTicketDetailsController> {
  const SupportTicketDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Obx(() {
            final ticket = controller.supportTicketDetails;
            final ticketNo = (ticket['ticket_id'] ?? ticket['id'] ?? ticket['_id'] ?? ticket['ticket_number'] ?? '').toString();
            final subject = (ticket['subject'] ?? '').toString();
            return Text(
              ticketNo.isEmpty ? 'Support Ticket' : '#\$ticketNo\${subject.isNotEmpty ? ' · \$subject' : ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium,
            );
          }),
          actions: [
            Obx(() {
              final ticket = controller.supportTicketDetails;
              if (ticket.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    _StatusChip(status: (ticket['status'] ?? 'new').toString()),
                    const SizedBox(width: 6),
                    _PriorityChip(priority: (ticket['priority'] ?? 'medium').toString()),
                  ],
                ),
              );
            }),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isChatLoading.isTrue && controller.chatMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (controller.chatMessages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.chatMessages.length,
                  itemBuilder: (context, index) {
                    final current = controller.chatMessages[index];
                    final next = (index + 1 < controller.chatMessages.length)
                        ? controller.chatMessages[index + 1]
                        : null;
                    final showDateSeparator = _shouldShowDateSeparator(current, next);
                    return Column(
                      children: [
                        _MessageBubble(message: current, colorScheme: colorScheme, textTheme: textTheme),
                        if (showDateSeparator) _DateSeparator(dateLabel: _formatDateLabel(current['created_at'])),
                      ],
                    );
                  },
                );
              }),
            ),
            Obx(() {
              final canReply = controller.supportTicketDetails['can_reply'] != false;
              if (!canReply) {
                return SafeArea(
                  top: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.1))),
                    ),
                    child: Text(
                      'This ticket is closed and can no longer be replied to.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ),
                );
              }
              return _InputArea(controller: controller, colorScheme: colorScheme);
            }),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateSeparator(dynamic current, dynamic next) {
    if (next == null) return true;
    final currentDate = DateTime.tryParse((current['created_at'] ?? '').toString());
    final nextDate = DateTime.tryParse((next['created_at'] ?? '').toString());
    if (currentDate == null || nextDate == null) return false;
    return currentDate.year != nextDate.year ||
        currentDate.month != nextDate.month ||
        currentDate.day != nextDate.day;
  }

  String _formatDateLabel(dynamic rawDate) {
    final date = DateTime.tryParse((rawDate ?? '').toString());
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) return 'Today';
    if (target == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.colorScheme, required this.textTheme});
  final dynamic message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final isCustomer = message['is_customer'] == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bubbleColor = isCustomer
        ? (primaryColor != Colors.transparent
            ? primaryColor.withOpacity(isDark ? 0.22 : 0.12)
            : colorScheme.primary.withOpacity(isDark ? 0.22 : 0.12))
        : colorScheme.onSurface.withOpacity(isDark ? 0.12 : 0.06);

    final rawDate = message['created_at']?.toString();
    final timeLabel = rawDate != null && DateTime.tryParse(rawDate) != null
        ? DateFormat('h:mm a').format(DateTime.parse(rawDate))
        : '';

    final text = (message['message'] ?? '').toString();

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatAttachmentWidget(messageData: message, isSender: isCustomer),
            if (text.trim().isNotEmpty) ...[
              isCustomer
                  ? Text(text, style: textTheme.bodyMedium)
                  : HtmlWidget(text),
              const SizedBox(height: 4),
            ],
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeLabel,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.dateLabel});
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    if (dateLabel.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            dateLabel,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = SupportTicketStatus.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = SupportTicketStatus.priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(priority, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _InputArea extends StatelessWidget {
  const _InputArea({required this.controller, required this.colorScheme});
  final SupportTicketDetailsController controller;
  final ColorScheme colorScheme;

  void _showAttachmentPicker(BuildContext context) {
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
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFFE91E63),
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickImageFromCamera();
                      },
                    ),
                    _PickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xFF9C27B0),
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickImageFromGallery();
                      },
                    ),
                    _PickerOption(
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      color: const Color(0xFFFF9800),
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickVideoFromGallery();
                      },
                    ),
                    _PickerOption(
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (controller.selectedFiles.isEmpty) return const SizedBox.shrink();
              final file = controller.selectedFiles.first;
              final fileName = file.path.split('/').last;
              final ext = fileName.split('.').last.toLowerCase();
              final isImage = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
              final isVideo = ['mp4', 'mov', 'mkv', 'webm', '3gp'].contains(ext);
              final isPdf = ext == 'pdf';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      if (isImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(file, width: 44, height: 44, fit: BoxFit.cover),
                        )
                      else
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isPdf
                                ? const Color(0xFFFFEBEE)
                                : (isVideo ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            isPdf
                                ? Icons.picture_as_pdf_rounded
                                : (isVideo ? Icons.videocam_rounded : Icons.description_rounded),
                            color: isPdf
                                ? const Color(0xFFE53935)
                                : (isVideo ? const Color(0xFFFF9800) : const Color(0xFF1E88E5)),
                            size: 24,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              isImage
                                  ? 'Photo ready to send'
                                  : (isVideo
                                      ? 'Video ready to send'
                                      : (isPdf ? 'PDF document ready to send' : 'Document ready to send')),
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, size: 20, color: Colors.red),
                        onPressed: () => controller.removeSelectedFile(file),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                      ),
                    ),
                  ),
                ),
                Obx(() => IconButton(
                      icon: Icon(
                        controller.selectedFiles.isEmpty ? Icons.attach_file : Icons.remove_circle_outline,
                        color: controller.selectedFiles.isEmpty ? colorScheme.onSurface.withOpacity(0.6) : Colors.red,
                      ),
                      onPressed: () {
                        if (controller.selectedFiles.isNotEmpty) {
                          controller.selectedFiles.clear();
                        } else {
                          _showAttachmentPicker(context);
                        }
                      },
                    )),
                Obx(() {
                  final canSend = controller.messageController.text.trim().isNotEmpty ||
                      controller.selectedFiles.isNotEmpty;
                  return GestureDetector(
                    onTap: controller.isMessageSendLoading.isTrue
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            controller.sendMessagesWithFiles(
                              message: controller.messageController.text,
                              files: controller.selectedFiles,
                            );
                          },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: canSend ? primaryColor : colorScheme.outline.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: controller.isMessageSendLoading.isTrue
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
