import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../controllers/support_ticket_details_controller.dart';

class SupportTicketDetailsView extends GetView<SupportTicketDetailsController> {
  const SupportTicketDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Obx(() {
            final ticket = controller.supportTicketDetails;
            final ticketNo = (ticket['id'] ?? ticket['_id'] ?? ticket['ticket_number'] ?? '').toString();
            final subject = (ticket['subject'] ?? '').toString();
            return Text(
              ticketNo.isEmpty ? 'Support Ticket' : '#$ticketNo${subject.isNotEmpty ? ' · $subject' : ''}',
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
                    _StatusChip(status: (ticket['status'] ?? 'open').toString()),
                    const SizedBox(width: 6),
                    _PriorityChip(priority: (ticket['priority'] ?? 'normal').toString()),
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
            _InputArea(controller: controller, colorScheme: colorScheme),
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

// ─── Chat Bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.colorScheme, required this.textTheme});
  final dynamic message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final isCustomer = (message['user'] ?? 'customer').toString() == 'customer';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isCustomer
        ? colorScheme.primary.withOpacity(isDark ? 0.22 : 0.12)
        : colorScheme.onSurface.withOpacity(isDark ? 0.12 : 0.06);

    final rawDate = message['created_at']?.toString();
    final timeLabel = rawDate != null && DateTime.tryParse(rawDate) != null
        ? DateFormat('h:mm a').format(DateTime.parse(rawDate))
        : '';

    final attachments = message['attachments'];
    final images = <Map<String, dynamic>>[];
    if (attachments is List) {
      for (final item in attachments) {
        if (item is Map) images.add(Map<String, dynamic>.from(item));
      }
    }

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isCustomer
                ? Text((message['message'] ?? '').toString(), style: textTheme.bodyMedium)
                : HtmlWidget((message['message'] ?? '').toString()),
            if (images.isNotEmpty) ...[
              const SizedBox(height: 8),
              _AttachmentGrid(images: images),
            ],
            const SizedBox(height: 4),
            Text(
              timeLabel,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentGrid extends StatelessWidget {
  const _AttachmentGrid({required this.images});
  final List<Map<String, dynamic>> images;

  @override
  Widget build(BuildContext context) {
    final visible = images.take(4).toList();
    final remaining = images.length - visible.length;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(visible.length, (index) {
        final imageUrl = HelperFunctions().getImage(visible[index]);
        final isLastVisible = index == visible.length - 1 && remaining > 0;
        return GestureDetector(
          onTap: () => Get.to(
            () => const _AttachmentPreview(),
            arguments: {'images': images},
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              if (isLastVisible)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+$remaining',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview();

  @override
  Widget build(BuildContext context) {
    final images = (Get.arguments?['images'] as List?) ?? [];
    final controller = PageController();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = HelperFunctions().getImage(images[index]);
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
            ),
          );
        },
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
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            dateLabel,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 11, fontWeight: FontWeight.w600),
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
    Color color;
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'solved':
      case 'completed':
      case 'close':
      case 'closed':
        color = Colors.green;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }
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
    Color color;
    switch (priority.toLowerCase()) {
      case 'critical':
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(priority, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Input Area ─────────────────────────────────────────────────────────────

class _InputArea extends StatelessWidget {
  const _InputArea({required this.controller, required this.colorScheme});
  final SupportTicketDetailsController controller;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.selectedFiles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final file = controller.selectedFiles[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(file, width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () => controller.removeSelectedFile(file),
                              child: const Icon(Icons.cancel, size: 18, color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
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
                      onPressed: () async {
                        if (controller.selectedFiles.isNotEmpty) {
                          controller.selectedFiles.clear();
                          return;
                        }
                        final picked = await ImagePicker().pickMultiImage();
                        controller.selectedFiles.addAll(picked.map((e) => File(e.path)));
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
                        color: canSend ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: controller.isMessageSendLoading.isTrue
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                            )
                          : Icon(Icons.send_rounded, size: 18, color: colorScheme.onPrimary),
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
