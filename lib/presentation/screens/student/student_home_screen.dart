import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/hostel_providers.dart';
import '../../providers/hostel_filters_provider.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/search/hostel_search_bar.dart';
import '../../widgets/search/search_results_view.dart';
import '../../widgets/filters/filter_chips.dart';
import 'hostel_search_map.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final viewMode        = ref.watch(viewModeProvider);
    final filteredHostels = ref.watch(filteredHostelsProvider);
    final userAsync       = ref.watch(currentUserProvider);
    final userName = userAsync.whenOrNull(data: (u) => u?.name.split(' ').first) ?? '';

    // Bottom padding for the glass nav bar
    const bottomPad = EdgeInsets.only(bottom: 100);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const AppDrawer(),
      body: PopScope(
        canPop: viewMode == ViewMode.list,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && viewMode == ViewMode.map) {
            ref.read(viewModeProvider.notifier).state = ViewMode.list;
          }
        },
        child: CustomScrollView(
          slivers: [
            // ── Cinematic Header ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              floating: true,
              pinned: false,
              snap: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(Icons.menu_rounded,
                        color: AppColors.textPrimary, size: 22),
                  ),
                ),
              ),
              actions: [
                // Map / List toggle
                GestureDetector(
                  onTap: () => ref.read(viewModeProvider.notifier).state =
                      viewMode == ViewMode.list ? ViewMode.map : ViewMode.list,
                  child: Container(
                    margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          viewMode == ViewMode.list
                              ? Icons.map_outlined
                              : Icons.view_list_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          viewMode == ViewMode.list ? 'Map' : 'List',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.fromLTRB(24.0, 80, 24.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeInDown(
                        child: Text(
                          userName.isNotEmpty
                              ? 'Good day, $userName 👋'
                              : 'Find your stay',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      FadeInDown(
                        delay: const Duration(milliseconds: 60),
                        child: Text(
                          'Discover Hostels',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Search Bar ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: FadeInUp(
                  child: HostelSearchBar(
                    onSearch: (query) => ref.read(hostelFiltersProvider.notifier).setSearchQuery(query),
                    onClear: () => ref.read(hostelFiltersProvider.notifier).setSearchQuery(null),
                  ),
                ),
              ),
            ),

            // ── Filter Chips ──────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: FilterChips(),
            ),

            // ── Content ───────────────────────────────────────────────────
            if (viewMode == ViewMode.map)
              SliverFillRemaining(
                child: Padding(
                  padding: bottomPad,
                  child: const HostelSearchMap(),
                ),
              )
            else
              SearchResultsView(hostelsAsync: filteredHostels),
          ],
        ),
      ),
    );
  }
}
