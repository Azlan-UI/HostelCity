import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum GenderType {
  boys,
  girls,
  mixed;

  String get displayName {
    switch (this) {
      case GenderType.boys:
        return 'Boys';
      case GenderType.girls:
        return 'Girls';
      case GenderType.mixed:
        return 'Mixed';
    }
  }

  Color get color {
    switch (this) {
      case GenderType.boys:
        return AppColors.boys;
      case GenderType.girls:
        return AppColors.girls;
      case GenderType.mixed:
        return AppColors.mixed;
    }
  }

  IconData get icon {
    switch (this) {
      case GenderType.boys:
        return Icons.male;
      case GenderType.girls:
        return Icons.female;
      case GenderType.mixed:
        return Icons.people;
    }
  }
}
