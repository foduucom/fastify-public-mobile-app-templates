import 'package:flutter/material.dart';

/// Single source of truth for support-ticket status/priority labels shared
/// between the ticket list and ticket detail screens.
///
/// Ported from SOURCE's `support_ticket_status.dart`, but the color mapping
/// below does NOT copy SOURCE's hardcoded `Colors.green/blue/orange/purple`.
/// Instead it follows TARGET's own order-status-chip convention (see
/// `_StatusBadge` in `Profie/orders/view/order_view.dart` and `_statusChip`
/// in `Profie/orders/order_products/view/order_products_view.dart`), which
/// buckets every status into one of `colorScheme.primary` (done/positive),
/// `colorScheme.secondary` (in progress/neutral) or `colorScheme.error`
/// (negative), falling back to `colorScheme.onSurfaceVariant`. That requires
/// a `ColorScheme` at call time, so these are instance-style helpers taking
/// a `ColorScheme` rather than SOURCE's static `Color` constants.
class SupportTicketStatus {
  SupportTicketStatus._();

  static const statuses = ['new', 'viewed', 'pending', 'resolved', 'closed'];
  static const priorities = ['low', 'medium', 'high'];

  /// Maps a ticket status to a themed color using TARGET's order-status
  /// convention: resolved/closed -> primary, viewed/pending -> secondary,
  /// new -> onSurfaceVariant (neutral/needs-attention default), anything
  /// unrecognized -> onSurfaceVariant.
  static Color statusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return colorScheme.primary;
      case 'viewed':
      case 'pending':
        return colorScheme.secondary;
      case 'new':
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  /// Maps a ticket priority to a themed color: high -> error,
  /// medium -> secondary, low -> primary.
  static Color priorityColor(String priority, ColorScheme colorScheme) {
    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme.error;
      case 'medium':
        return colorScheme.secondary;
      case 'low':
      default:
        return colorScheme.primary;
    }
  }
}
