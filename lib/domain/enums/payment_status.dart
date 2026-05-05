import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum PaymentStatus {
  pending,
  paid,
  overdue;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.overdue:
        return 'Overdue';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return AppColors.pending;
      case PaymentStatus.paid:
        return AppColors.paid;
      case PaymentStatus.overdue:
        return AppColors.overdue;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.overdue:
        return Icons.warning;
    }
  }
}
