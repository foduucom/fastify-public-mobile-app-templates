import 'package:flutter/material.dart';

/// Single source of truth for support-ticket status/priority colors and labels,
/// shared between the ticket list and ticket detail screens.
class SupportTicketStatus {
  SupportTicketStatus._();

  static const statuses = ['new', 'viewed', 'pending', 'resolved', 'closed'];
  static const priorities = ['low', 'medium', 'high'];

  static Color statusColor(String status, [ColorScheme? colorScheme]) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return colorScheme?.primary ?? Colors.green;
      case 'viewed':
        return Colors.blue;
      case 'pending':
        return colorScheme?.secondary ?? Colors.orange;
      case 'new':
      default:
        return colorScheme?.onSurfaceVariant ?? Colors.purple;
    }
  }

  static Color priorityColor(String priority, [ColorScheme? colorScheme]) {
    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme?.error ?? Colors.red;
      case 'medium':
        return colorScheme?.secondary ?? Colors.orange;
      case 'low':
      default:
        return colorScheme?.primary ?? Colors.green;
    }
  }
}
