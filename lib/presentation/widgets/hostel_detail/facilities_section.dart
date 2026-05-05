import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:animate_do/animate_do.dart';


class FacilitiesSection extends StatelessWidget {
  final List<String> facilities;

  const FacilitiesSection({super.key, required this.facilities});

  @override
  Widget build(BuildContext context) {
    if (facilities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('Facilities & Amenities', style: Theme.of(context).textTheme.titleLarge!),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: facilities.length,
            itemBuilder: (context, i) {
              return FadeInUp(
                duration: const Duration(milliseconds: 250),
                delay: Duration(milliseconds: i * 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _facilityIcon(facilities[i]),
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        facilities[i],
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _facilityIcon(String facility) {
    switch (facility.toLowerCase()) {
      case 'wifi':
      case 'wi-fi':
        return Icons.wifi_rounded;
      case 'mess':
      case 'cafeteria':
      case 'food':
        return Icons.restaurant_rounded;
      case 'laundry':
        return Icons.local_laundry_service_rounded;
      case 'security':
      case 'cctv':
        return Icons.security_rounded;
      case 'parking':
        return Icons.local_parking_rounded;
      case 'study area':
      case 'library':
        return Icons.menu_book_rounded;
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'generator':
      case 'backup power':
        return Icons.bolt_rounded;
      case 'water':
      case 'water supply':
        return Icons.water_drop_rounded;
      case 'ac':
      case 'air conditioning':
        return Icons.ac_unit_rounded;
      case 'medical':
      case 'clinic':
        return Icons.local_hospital_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }
}
