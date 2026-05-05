import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/hostel_filters_provider.dart';

// ─── Location Sheet ────────────────────────────────────────────────────────
class LocationFilterSheet extends ConsumerStatefulWidget {
  const LocationFilterSheet({super.key});

  @override
  ConsumerState<LocationFilterSheet> createState() => _LocationFilterSheetState();
}

class _LocationFilterSheetState extends ConsumerState<LocationFilterSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentLoc = ref.read(hostelFiltersProvider).location;
    _controller = TextEditingController(text: currentLoc);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
        top: 16.0,
        left: 24.0,
        right: 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter by Location', style: Theme.of(context).textTheme.headlineSmall),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 24.0),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter city or area name',
              prefixIcon: Icon(Icons.place_rounded, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                ref.read(hostelFiltersProvider.notifier).setLocation(_controller.text);
                Navigator.pop(context);
              },
              child: const Text('Apply Location', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ─── Price Sheet ──────────────────────────────────────────────────────────
class PriceFilterSheet extends ConsumerStatefulWidget {
  const PriceFilterSheet({super.key});

  @override
  ConsumerState<PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends ConsumerState<PriceFilterSheet> {
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(hostelFiltersProvider);
    _range = RangeValues(filters.priceMin ?? 0, filters.priceMax ?? 100000);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price Range', style: Theme.of(context).textTheme.headlineSmall),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 24.0),
          Text(
            'Rs. ${_range.start.toInt()} – ${_range.end.toInt()}',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: AppColors.accent),
          ),
          SizedBox(height: 16.0),
          RangeSlider(
            values: _range,
            min: 0,
            max: 100000,
            divisions: 100,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.surfaceAlt,
            onChanged: (values) => setState(() => _range = values),
          ),
          SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                ref.read(hostelFiltersProvider.notifier).setPriceRange(_range.start, _range.end);
                Navigator.pop(context);
              },
              child: const Text('Apply Price', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sorting Sheet ────────────────────────────────────────────────────────
class SortingSheet extends ConsumerWidget {
  const SortingSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(hostelFiltersProvider).sortBy;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sort By', style: Theme.of(context).textTheme.headlineSmall),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          _buildSortOption(context, ref, 'relevance', 'Recommended', currentSort),
          _buildSortOption(context, ref, 'price_low', 'Price: Low to High', currentSort),
          _buildSortOption(context, ref, 'price_high', 'Price: High to Low', currentSort),
          _buildSortOption(context, ref, 'rating', 'Highest Rated / Occupied', currentSort),
        ],
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, WidgetRef ref, String value, String label, String currentSort) {
    final isSelected = currentSort == value;
    
    return GestureDetector(
      onTap: () {
        ref.read(hostelFiltersProvider.notifier).setSorting(value);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
            SizedBox(width: 16.0),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
