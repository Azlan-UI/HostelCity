import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/hostel_filters_provider.dart';

class HostelSearchBar extends ConsumerStatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClear;

  const HostelSearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
  });

  @override
  ConsumerState<HostelSearchBar> createState() => _HostelSearchBarState();
}

class _HostelSearchBarState extends ConsumerState<HostelSearchBar> {
  late TextEditingController _controller;
  bool _isExpanded = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref.watch(recentSearchesProvider);
    
    return Column(
      children: [
        // Search bar container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _isExpanded 
              ? AppColors.surface 
              : AppColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isExpanded 
                ? AppColors.accent 
                : AppColors.accent.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: _isExpanded ? [const BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))] : null,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 12),
                child: Icon(
                  Icons.search_rounded,
                  color: _isExpanded ? AppColors.accent : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              Expanded(
                child: Focus(
                  onFocusChange: (focused) => setState(() => _isExpanded = focused),
                  child: TextField(
                    controller: _controller,
                    onTap: () => setState(() => _showSuggestions = true),
                    onChanged: (value) {
                      widget.onSearch(value);
                      setState(() => _showSuggestions = value.isNotEmpty || recentSearches.isNotEmpty);
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        ref.read(recentSearchesProvider.notifier).addSearch(value);
                      }
                      setState(() {
                        _showSuggestions = false;
                        _isExpanded = false;
                      });
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search hostels, cities, areas...',
                      hintStyle: Theme.of(context).textTheme.bodySmall!,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      isDense: true,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onClear();
                    setState(() => _showSuggestions = recentSearches.isNotEmpty);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 20),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Suggestions dropdown
        if (_showSuggestions && _controller.text.isEmpty && recentSearches.isNotEmpty)
          FadeInDown(
            duration: const Duration(milliseconds: 200),
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [const BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: recentSearches.take(5).map((search) {
                  return GestureDetector(
                    onTap: () {
                      _controller.text = search;
                      widget.onSearch(search);
                      setState(() {
                        _showSuggestions = false;
                        _isExpanded = false;
                      });
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      color: Colors.transparent, // Ensures entire row is clickable
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 16.0),
                          Text(search, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
