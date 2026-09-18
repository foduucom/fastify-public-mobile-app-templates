import 'package:flutter/material.dart';

/// Single source of truth for support-ticket status/priority colors and labels,
/// shared between the ticket list and ticket detail screens.
class SupportTicketStatus {
  static const statuses = ['new', 'viewed', 'pending', 'resolved', 'closed'];
  static const priorities = ['low', 'medium', 'high'];

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return Colors.green;
      case 'viewed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'new':
      default:
        return Colors.purple;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }
}
