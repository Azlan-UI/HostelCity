import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:animate_do/animate_do.dart';


class RulesSection extends StatelessWidget {
  final List<String> rules;

  const RulesSection({super.key, required this.rules});

  static const List<IconData> _ruleIcons = [
    Icons.schedule_rounded,
    Icons.no_drinks_rounded,
    Icons.no_photography_rounded,
    Icons.cleaning_services_rounded,
    Icons.do_not_disturb_rounded,
    Icons.lock_rounded,
    Icons.door_front_door_rounded,
    Icons.smoke_free_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('Rules & Regulations', style: Theme.of(context).textTheme.titleLarge!),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: rules.asMap().entries.map((entry) {
              final i = entry.key;
              final rule = entry.value;
              final icon = _ruleIcons[i % _ruleIcons.length];
              return FadeInLeft(
                duration: const Duration(milliseconds: 250),
                delay: Duration(milliseconds: i * 50),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 16, color: AppColors.accent),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          rule,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
