import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/app/modules/support_ticket/controller/supportticket_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class SupportTicketView extends GetView<SupportTicketController> {
  const SupportTicketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Support Tickets',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: context.themeTextColor,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: context.themeTextColor,
        ),
        floatingActionButton: Obx(() {
          if (controller.isLoading.value || controller.supportTickets.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showGenerateTicketBottomSheet(context),
            backgroundColor: themePrimaryColor,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Generate Ticket',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.getSupportTickets();
          },
          color: themePrimaryColor,
          child: Obx(
            () => controller.isLoading.value
                ? _buildShimmerEffect(context)
                : controller.supportTickets.isNotEmpty
                    ? ListView.builder(
                        controller: controller.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: controller.supportTickets.length +
                            (controller.isLoadMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= controller.supportTickets.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: HelperFunctions().loadingIndicator(),
                              ),
                            );
                          }
                          final ticket = controller.supportTickets[index];
                          final isNew =
                              index < 2; // Example logic for "NEW" badge
                          return _buildTicketCard(
                              context, ticket, index, isNew);
                        },
                      )
                    : _buildEmptyState(context),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(
      BuildContext context, dynamic ticket, int index, bool isNew) {
    final ticketId = ticket['ticket_id']?.toString() ?? 'N/A';
    final subject = ticket['subject'] ?? 'No Subject';
    final message = ticket['message'] ?? '';
    final status = ticket['status'] ?? 'pending';
    final priority = ticket['priority'] ?? 'low';
    final createdAt = ticket['created_at'] ?? '';

    return Card(
      elevation: 1,
      color: context.themeWhiteColor,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.themeBorderColor,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Ticket ID, Status, NEW badge
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.themegreyColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'TKT-$ticketId',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: context.themeTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(status),
                ],
              ),
              const SizedBox(height: 12),
              // Subject
              Text(
                subject,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.themeTextColor,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Message Preview
              if (message.isNotEmpty)
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.themeSecondrytext,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 14),
              // Divider with priority and actions
              Row(
                children: [
                  _buildPriorityBadge(priority),
                  const Spacer(),
                  Text(
                    HelperFunctions().toCarbonToHumanDateFormat(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.themeSecondrytext,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.visibility_outlined,
                    color: Colors.blueAccent,
                    tooltip: 'View Details',
                    onTap: () {
                      Get.toNamed(Routes.SUPPORTTICKETDETAILS, arguments: {
                        'id': ticket['id'] ??
                            ticket['_id'] ??
                            ticket['ticket_number']
                      });
                    },
                  ),
                  if (ticket['can_reply'] != false &&
                      !['closed', 'close', 'resolved'].contains(
                          status.toString().toLowerCase())) ...[
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: Icons.lock_outline,
                      color: Colors.redAccent,
                      tooltip: 'Close Ticket',
                      onTap: () => _confirmCloseTicket(context, ticket, index),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.08),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusMap = {
      'resolved': {
        'bg': const Color(0xFFE8F5E9),
        'text': const Color(0xFF3C8A38),
        'label': 'Resolved'
      },
      'solved': {
        'bg': const Color(0xFFE8F5E9),
        'text': const Color(0xFF3C8A38),
        'label': 'Resolved'
      },
      'completed': {
        'bg': const Color(0xFFE8F5E9),
        'text': const Color(0xFF3C8A38),
        'label': 'Completed'
      },
      'close': {
        'bg': const Color(0xFFE8F5E9),
        'text': const Color(0xFF3C8A38),
        'label': 'Closed'
      },
      'closed': {
        'bg': const Color(0xFFE8F5E9),
        'text': const Color(0xFF3C8A38),
        'label': 'Closed'
      },
      'new': {
        'bg': const Color(0xFFE3F2FD),
        'text': const Color(0xFF20558A),
        'label': 'New'
      },
      'viewed': {
        'bg': const Color(0xFFECEFF1),
        'text': const Color(0xFF455A64),
        'label': 'Viewed'
      },
      'pending': {
        'bg': const Color(0xFFFFF8E1),
        'text': const Color(0xFFF57F17),
        'label': 'Pending'
      },
      'in_progress': {
        'bg': const Color(0xFFE3F2FD),
        'text': const Color(0xFF20558A),
        'label': 'In Progress'
      },
      'open': {
        'bg': const Color(0xFFE3F2FD),
        'text': const Color(0xFF20558A),
        'label': 'Open'
      },
    };

    final key = status.toLowerCase();
    final data = statusMap[key] ??
        {
          'bg': const Color(0xFFECEFF1),
          'text': const Color(0xFF455A64),
          'label': status
        };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: data['bg'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        (data['label'] as String).toUpperCase(),
        style: TextStyle(
          color: data['text'] as Color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final priorityMap = {
      'critical': {
        'bg': const Color(0xFFFFEBEE),
        'text': const Color(0xFFC62828),
        'icon': Icons.priority_high
      },
      'high': {
        'bg': const Color(0xFFFFEBEE),
        'text': const Color(0xFFC62828),
        'icon': Icons.priority_high
      },
      'medium': {
        'bg': const Color(0xFFE3F2FD),
        'text': const Color(0xFF20558A),
        'icon': Icons.flag
      },
      'low': {
        'bg': const Color(0xFFF5F5F5),
        'text': const Color(0xFF616161),
        'icon': Icons.flag
      },
      'normal': {
        'bg': const Color(0xFFF5F5F5),
        'text': const Color(0xFF616161),
        'icon': Icons.flag
      },
    };

    final key = priority.toLowerCase();
    final data = priorityMap[key] ?? priorityMap['low']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: data['bg'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data['icon'] as IconData,
            size: 12,
            color: data['text'] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              color: data['text'] as Color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent_outlined,
            size: 64,
            color: context.themeSecondrytext,
          ),
          const SizedBox(height: 16),
          Text(
            'No support tickets available',
            style: TextStyle(
              fontSize: 16,
              color: context.themeTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a new ticket to get started',
            style: TextStyle(
              fontSize: 14,
              color: context.themeSecondrytext,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showGenerateTicketBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: themePrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Generate Ticket'),
          ),
        ],
      ),
    );
  }

  void _confirmCloseTicket(BuildContext context, dynamic ticket, int index) {
    final ticketId = ticket['id'] ?? ticket['_id'] ?? '';
    if (ticketId.toString().isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.themeWhiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Close Ticket?',
              style: TextStyle(color: context.themeTextColor)),
          content: Text(
              'Are you sure you want to close this support ticket? You will not be able to reply to it afterwards.',
              style: TextStyle(color: context.themeSecondrytext)),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('CANCEL',
                  style: TextStyle(color: context.themeSecondrytext)),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                bool success = await controller.closeSupportTicket(
                    ticketId.toString(), index);
                if (success) {
                  Get.snackbar(
                    'Success',
                    'Ticket closed successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 8,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to close ticket. Please try again.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 8,
                  );
                }
              },
              child: const Text('CLOSE',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showGenerateTicketBottomSheet(BuildContext context) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    var selectedPriority = 'Low'.obs;
    var selectedTicketType = 'General Inquiry'.obs;
    final selectedFile = Rxn<File>();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: context.themeWhiteColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.themeBorderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Create Support Ticket',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.themeTextColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Subject Field
                    TextFormField(
                      controller: subjectController,
                      style: TextStyle(
                          color: context.themeTextColor, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        labelStyle: TextStyle(color: context.themeSecondrytext),
                        hintText: 'What is the issue about?',
                        hintStyle: TextStyle(color: context.themeSecondrytext),
                        fillColor: context.themegreyColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: context.themeBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: context.themeBorderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Ticket Type Dropdown
                    Obx(() => DropdownButtonFormField<String>(
                          value: selectedTicketType.value,
                          dropdownColor: context.themeWhiteColor,
                          decoration: InputDecoration(
                            labelText: 'Ticket Type',
                            labelStyle:
                                TextStyle(color: context.themeSecondrytext),
                            hintText: 'Select the type of issue',
                            hintStyle:
                                TextStyle(color: context.themeSecondrytext),
                            fillColor: context.themegreyColor,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: context.themeBorderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: context.themeBorderColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: context.themeTextColor,
                          ),
                          iconSize: 28,
                          elevation: 2,
                          style: TextStyle(
                            fontSize: 15,
                            color: context.themeTextColor,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Billing',
                              child: Text('Billing',
                                  style:
                                      TextStyle(color: context.themeTextColor)),
                            ),
                            DropdownMenuItem(
                              value: 'Technical',
                              child: Text('Technical',
                                  style:
                                      TextStyle(color: context.themeTextColor)),
                            ),
                            DropdownMenuItem(
                              value: 'General Inquiry',
                              child: Text('General Inquiry',
                                  style:
                                      TextStyle(color: context.themeTextColor)),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              selectedTicketType.value = value;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a ticket type';
                            }
                            return null;
                          },
                        )),
                    const SizedBox(height: 16),
                    // Message Field
                    TextFormField(
                      controller: messageController,
                      maxLines: 4,
                      style: TextStyle(
                          color: context.themeTextColor, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: context.themeSecondrytext),
                        hintText: 'Describe your issue in detail...',
                        hintStyle: TextStyle(color: context.themeSecondrytext),
                        fillColor: context.themegreyColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: context.themeBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: context.themeBorderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Priority Selection
                    Text(
                      'Priority Level',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.themeSecondrytext,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Low', 'Medium', 'High'].map((priority) {
                            final isSelected =
                                selectedPriority.value == priority;
                            Color chipColor;
                            Color textColor;
                            if (isSelected) {
                              switch (priority) {
                                case 'High':
                                  chipColor = const Color(0xFFC62828);
                                  textColor = Colors.white;
                                  break;
                                case 'Medium':
                                  chipColor = const Color(0xFF20558A);
                                  textColor = Colors.white;
                                  break;
                                case 'Low':
                                default:
                                  chipColor = themePrimaryColor;
                                  textColor = Colors.white;
                              }
                            } else {
                              chipColor = context.themegreyColor;
                              textColor = context.themeTextColor;
                            }

                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  label: Center(
                                    child: Text(
                                      priority,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: chipColor,
                                  backgroundColor: chipColor,
                                  showCheckmark: false,
                                  onSelected: (bool selected) {
                                    if (selected) {
                                      selectedPriority.value = priority;
                                    }
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                    const SizedBox(height: 20),
                    // Attachment section
                    Text(
                      'Attachment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.themeSecondrytext,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final file = selectedFile.value;
                      if (file != null) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.themegreyColor,
                            border: Border.all(color: context.themeBorderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  file,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.path.split('/').last,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.themeTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<int>(
                                      future: file.length(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final kb = snapshot.data! / 1024;
                                          return Text(
                                            '${kb.toStringAsFixed(1)} KB',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context.themeSecondrytext,
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                                onPressed: () {
                                  selectedFile.value = null;
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      return InkWell(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? photo = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (photo != null) {
                            selectedFile.value = File(photo.path);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.themeBorderColor,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: context.themegreyColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 32,
                                color: context.themeSecondrytext,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload attachment image',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.themeTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Supports PNG, JPG, JPEG',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.themeSecondrytext,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      bool success =
                                          await controller.createSupportTicket(
                                        subject: subjectController.text,
                                        message: messageController.text,
                                        priority: selectedPriority.value,
                                        ticketType: selectedTicketType.value,
                                        files: selectedFile.value != null
                                            ? [selectedFile.value!]
                                            : null,
                                      );
                                      if (success) {
                                        Get.back();
                                        Get.snackbar(
                                          'Success',
                                          'Ticket created successfully',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                          margin: const EdgeInsets.all(16),
                                          borderRadius: 8,
                                        );
                                      } else {
                                        Get.snackbar(
                                          'Error',
                                          'Failed to create ticket. Please try again.',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          margin: const EdgeInsets.all(16),
                                          borderRadius: 8,
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themePrimaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Submit Ticket',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: context.isDark ? Colors.grey[800]! : Colors.grey.shade300,
          highlightColor:
              context.isDark ? Colors.grey[700]! : Colors.grey.shade100,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: 80,
                          height: 16,
                          color: context.themeWhiteColor),
                      Container(
                          width: 60,
                          height: 12,
                          color: context.themeWhiteColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                      width: 200, height: 18, color: context.themeWhiteColor),
                  const SizedBox(height: 8),
                  Container(
                      width: double.infinity,
                      height: 14,
                      color: context.themeWhiteColor),
                  const SizedBox(height: 4),
                  Container(
                      width: 150, height: 14, color: context.themeWhiteColor),
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 70,
                              height: 24,
                              color: context.themeWhiteColor),
                          const SizedBox(width: 8),
                          Container(
                              width: 60,
                              height: 24,
                              color: context.themeWhiteColor),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              width: 32,
                              height: 32,
                              color: context.themeWhiteColor),
                          const SizedBox(width: 8),
                          Container(
                              width: 32,
                              height: 32,
                              color: context.themeWhiteColor),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
