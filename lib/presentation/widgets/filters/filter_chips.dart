import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/hostel_filters_provider.dart';
import 'filter_sheets.dart';

class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(hostelFiltersProvider);
    final activeFilterCount = filters.countActive();
    
    return Column(
      children: [
        // Filter summary
        if (activeFilterCount > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$activeFilterCount active filters applied',
                  style: Theme.of(context).textTheme.bodySmall!,
                ),
                GestureDetector(
                  onTap: () => ref.read(hostelFiltersProvider.notifier).reset(),
                  child: Text(
                    'Clear all',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Filter chips (horizontal scroll)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isActive: activeFilterCount == 0,
                onTap: () => ref.read(hostelFiltersProvider.notifier).clearFilters(),
              ),
              SizedBox(width: 8.0),
              _FilterChip(
                label: 'Location',
                isActive: filters.location != null && filters.location!.isNotEmpty,
                onTap: () => _showLocationFilter(context, ref),
              ),
              SizedBox(width: 8.0),
              _FilterChip(
                label: 'Price',
                isActive: filters.priceMin != null || filters.priceMax != null,
                onTap: () => _showPriceFilter(context, ref),
              ),
              SizedBox(width: 8.0),
              _FilterChip(
                label: 'Sort: ${filters.sortBy}',
                isActive: filters.sortBy != 'relevance',
                onTap: () => _showSortingOptions(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showLocationFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationFilterSheet(),
    );
  }
  
  void _showPriceFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const PriceFilterSheet(),
    );
  }
  
  void _showSortingOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const SortingSheet(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive 
            ? AppColors.accent.withValues(alpha: 0.15) 
            : AppColors.surfaceAlt,
          border: Border.all(
            color: isActive 
              ? AppColors.accent 
              : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: isActive ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
