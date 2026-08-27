import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/support_ticket_controller.dart';

class SupportTicketView extends GetView<SupportTicketController> {
  const SupportTicketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support Tickets'),
          elevation: 0,
        ),
        floatingActionButton: Obx(() {
          if (controller.isLoading.isTrue && controller.supportTickets.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: const Icon(Icons.add),
            label: const Text('Generate Ticket'),
            onPressed: () => _showGenerateTicketBottomSheet(context, colorScheme, textTheme),
          );
        }),
        body: RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: () => controller.getSupportTickets(),
          child: Obx(() {
            if (controller.isLoading.isTrue && controller.supportTickets.isEmpty) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => _TicketCardShimmer(colorScheme: colorScheme),
              );
            }

            if (controller.supportTickets.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: _EmptyState(colorScheme: colorScheme, textTheme: textTheme),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: controller.supportTickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = controller.supportTickets[index];
                return _TicketCard(
                  ticket: ticket,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  onView: () {
                    final id = ticket['id'] ?? ticket['_id'] ?? ticket['ticket_number'];
                    Get.toNamed(Routes.SUPPORT_TICKET_DETAILS, arguments: {'id': id});
                  },
                  onDelete: () => _confirmDeleteTicket(context, colorScheme, ticket, index),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _confirmDeleteTicket(
      BuildContext context, ColorScheme colorScheme, dynamic ticket, int index) {
    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('Delete Ticket', style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          'Are you sure you want to delete this support ticket?',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              final id = (ticket['id'] ?? ticket['_id']).toString();
              controller.deleteSupportTicket(id, index);
            },
            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showGenerateTicketBottomSheet(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final formKey = GlobalKey<FormState>();
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    final ticketTypes = ['Billing', 'Technical', 'General Inquiry'];
    final priorities = ['Low', 'Medium', 'High'];
    final selectedType = ticketTypes.first.obs;
    final selectedPriority = priorities.first.obs;
    final selectedFile = Rxn<File>();
    final isSubmitting = false.obs;

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Generate Ticket',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: subjectController,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Subject is required' : null,
                  ),
                  const SizedBox(height: 12),
                  Obx(() => DropdownButtonFormField<String>(
                        value: selectedType.value,
                        decoration: const InputDecoration(labelText: 'Ticket Type'),
                        items: ticketTypes
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedType.value = value;
                        },
                      )),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 12),
                  Text('Priority', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                        spacing: 8,
                        children: priorities.map((priority) {
                          final selected = selectedPriority.value == priority;
                          final color = _priorityColor(priority);
                          return ChoiceChip(
                            label: Text(priority),
                            selected: selected,
                            selectedColor: color.withOpacity(0.15),
                            labelStyle: TextStyle(color: selected ? color : colorScheme.onSurface),
                            onSelected: (_) => selectedPriority.value = priority,
                          );
                        }).toList(),
                      )),
                  const SizedBox(height: 12),
                  Obx(() => selectedFile.value == null
                      ? OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (picked != null) selectedFile.value = File(picked.path);
                          },
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Attach Image'),
                        )
                      : Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(selectedFile.value!, width: 48, height: 48, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FutureBuilder<int>(
                                future: selectedFile.value!.length(),
                                builder: (context, snapshot) => Text(
                                  snapshot.hasData
                                      ? '${(snapshot.data! / 1024).toStringAsFixed(1)} KB'
                                      : 'Loading...',
                                  style: textTheme.bodySmall,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => selectedFile.value = null,
                            ),
                          ],
                        )),
                  const SizedBox(height: 20),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting.value
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  isSubmitting.value = true;
                                  final success = await controller.createSupportTicket(
                                    subject: subjectController.text.trim(),
                                    message: descriptionController.text.trim(),
                                    priority: selectedPriority.value,
                                    ticketType: selectedType.value,
                                    files: selectedFile.value != null ? [selectedFile.value!] : const [],
                                  );
                                  isSubmitting.value = false;
                                  if (success) Get.back();
                                },
                          child: isSubmitting.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Submit'),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

// ─── Ticket Card ────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.colorScheme,
    required this.textTheme,
    required this.onView,
    required this.onDelete,
  });

  final dynamic ticket;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final id = (ticket['id'] ?? ticket['_id'] ?? '').toString();
    final subject = (ticket['subject'] ?? '').toString();
    final message = (ticket['message'] ?? '').toString();
    final status = (ticket['status'] ?? 'open').toString();
    final priority = (ticket['priority'] ?? 'normal').toString();
    final createdAt = ticket['created_at']?.toString();
    final createdDate =
        (createdAt != null && createdAt.isNotEmpty) ? HelperFunctions().toCarbonToHumanDateFormat(createdAt) : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('TKT-$id', style: textTheme.labelSmall),
              ),
              const Spacer(),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text(subject, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _PriorityBadge(priority: priority),
              const Spacer(),
              if (createdDate.isNotEmpty)
                Text(createdDate,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.4))),
              const SizedBox(width: 8),
              InkWell(
                onTap: onView,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.visibility_outlined, size: 18, color: colorScheme.primary),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
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
      case 'pending':
      case 'open':
        color = Colors.orange;
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (priority.toLowerCase()) {
      case 'critical':
      case 'high':
        color = Colors.red;
        icon = Icons.keyboard_double_arrow_up;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.drag_handle;
        break;
      default:
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(priority, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Empty / Shimmer ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colorScheme, required this.textTheme});
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: colorScheme.onSurface.withOpacity(0.06), shape: BoxShape.circle),
            child: Icon(Icons.confirmation_num_outlined, size: 48, color: colorScheme.onSurface.withOpacity(0.35)),
          ),
          const SizedBox(height: 20),
          Text('No Support Tickets', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Tap "Generate Ticket" to raise a new support request.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

class _TicketCardShimmer extends StatelessWidget {
  const _TicketCardShimmer({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? colorScheme.surfaceVariant : Colors.grey.shade300;
    final highlight = isDark ? colorScheme.surface : Colors.white;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 12, width: 100, color: base),
            const SizedBox(height: 10),
            Container(height: 12, width: double.infinity, color: base),
            const SizedBox(height: 8),
            Container(height: 10, width: 150, color: base),
          ],
        ),
      ),
    );
  }
}
