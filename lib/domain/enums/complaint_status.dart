import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ComplaintStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get displayName {
    switch (this) {
      case ComplaintStatus.open:
        return 'Open';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.closed:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case ComplaintStatus.open:
        return AppColors.complaintOpen;
      case ComplaintStatus.inProgress:
        return AppColors.complaintInProgress;
      case ComplaintStatus.resolved:
        return AppColors.complaintResolved;
      case ComplaintStatus.closed:
        return AppColors.complaintClosed;
    }
  }

  IconData get icon {
    switch (this) {
      case ComplaintStatus.open:
        return Icons.error_outline;
      case ComplaintStatus.inProgress:
        return Icons.autorenew;
      case ComplaintStatus.resolved:
        return Icons.check_circle_outline;
      case ComplaintStatus.closed:
        return Icons.cancel_outlined;
    }
  }
}
