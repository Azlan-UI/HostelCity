import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/router/app_router.dart';
import '../../../data/models/hostel_model.dart';
import '../../providers/admin_providers.dart';
import '../../providers/admin_nav_provider.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/stat_pill.dart';
import '../../widgets/hostel/hostel_list_row.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/common/section_header.dart';

class HostelAdminDashboardScreen extends ConsumerStatefulWidget {
  const HostelAdminDashboardScreen({super.key});

  @override
  ConsumerState<HostelAdminDashboardScreen> createState() => _HostelAdminDashboardScreenState();
}

class _HostelAdminDashboardScreenState extends ConsumerState<HostelAdminDashboardScreen> {
  bool _showAllHostels = false;

  @override
  Widget build(BuildContext context) {
    // GUARD 1: Wait for auth stream to fully resolve before doing anything.
    // This prevents the screen from rendering while auth is still initializing
    // (the primary cause of permission-denied errors after logout → login).
    final authState = ref.watch(authStateProvider);
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (authState.value == null) {
      // Auth resolved but no user — should not normally reach here
      // because the router guards this route. Safety net.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed(AppRouter.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Please login')),
          );
        }

        // Get hostels managed by this admin - SECURITY: Strict isolation
        final hostelsAsync = ref.watch(hostelsByAdminProvider(user.userId));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
          ),
          drawer: const AppDrawer(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.addHostel);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Hostel'),
          ),
          body: hostelsAsync.when(
            data: (hostels) {
              if (hostels.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildDashboard(context, ref, hostels, user.userId);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorFallback(context, ref, error),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: _buildErrorFallback(context, ref, error),
      ),
    );
  }

  Widget _buildErrorFallback(BuildContext context, WidgetRef ref, Object error) {
    final isPermissionDenied = error.toString().contains('permission-denied') ||
        error.toString().contains('PERMISSION_DENIED') ||
        error.toString().contains('Access Denied');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPermissionDenied ? Icons.lock_outline_rounded : Icons.error_outline_rounded,
              size: 64,
              color: isPermissionDenied ? AppColors.warning : AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              isPermissionDenied ? 'Session Expired' : 'Something Went Wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isPermissionDenied
                  ? 'Your session has expired. Please sign in again to continue.'
                  : 'Failed to load dashboard data. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isPermissionDenied)
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRouter.login);
                  }
                },
                icon: const Icon(Icons.login_rounded),
                label: const Text('Sign In Again'),
              )
            else
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(currentUserProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 100,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'No Hostels Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first hostel to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.addHostel);
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Hostel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    List<HostelModel> hostels,
    String adminId,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(hostelsByAdminProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: 24),
            _buildStatisticsSection(context, ref, hostels),

            const SizedBox(height: 24),
            _buildQuickActionsSection(context, ref, hostels),
            const SizedBox(height: 24),
            _buildHostelsSection(context, hostels),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s an overview of your hostels',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    WidgetRef ref,
    List<HostelModel> hostels,
  ) {
    int totalResidents = 0;
    int totalComplaints = 0;
    double avgOccupancy = 0;

    for (final hostel in hostels) {
      final residentsAsync = ref.watch(activeResidentsCountProvider(hostel.hostelId));
      final complaintsAsync = ref.watch(pendingComplaintsCountProvider(hostel.hostelId));

      residentsAsync.whenData((count) => totalResidents += count);
      complaintsAsync.whenData((count) => totalComplaints += count);
      avgOccupancy += hostel.occupancyRate;
    }

    if (hostels.isNotEmpty) {
      avgOccupancy /= hostels.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            children: [
              StatPill(
                label: 'Total Hostels',
                value: hostels.length.toString(),
                icon: Icons.home_work,
                baseColor: AppColors.primary,
              ),
              const SizedBox(width: 12),
              StatPill(
                label: 'Residents',
                value: totalResidents.toString(),
                icon: Icons.people,
                baseColor: AppColors.success,
              ),
              const SizedBox(width: 12),
              StatPill(
                label: 'Avg Occupancy',
                value: '${avgOccupancy.toStringAsFixed(0)}%',
                icon: Icons.pie_chart,
                baseColor: AppColors.info,
              ),
              const SizedBox(width: 12),
              StatPill(
                label: 'Pending Issues',
                value: totalComplaints.toString(),
                icon: Icons.report_problem,
                baseColor: AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    WidgetRef ref,
    List<HostelModel> hostels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionChip(
              context,
              icon: Icons.report,
              title: 'Complaints',
              color: AppColors.warning,
              onTap: () => ref.read(adminNavIndexProvider.notifier).state = 2,
            ),
            _buildActionChip(
              context,
              icon: Icons.people,
              title: 'Residents',
              color: AppColors.success,
              onTap: () => ref.read(adminNavIndexProvider.notifier).state = 3,
            ),
            _buildActionChip(
              context,
              icon: Icons.payment,
              title: 'Dues',
              color: AppColors.primary,
              onTap: () => ref.read(adminNavIndexProvider.notifier).state = 1,
            ),
            _buildActionChip(
              context,
              icon: Icons.campaign,
              title: 'Notices',
              color: AppColors.info,
              onTap: () => Navigator.pushNamed(context, AppRouter.adminPostNotice),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: onTap,
    );
  }

  Widget _buildHostelsSection(BuildContext context, List<HostelModel> hostels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Your Hostels',
          actionLabel: hostels.length > 2 ? (_showAllHostels ? 'See Less' : 'See More') : null,
          onAction: () {
            setState(() {
              _showAllHostels = !_showAllHostels;
            });
          },
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _showAllHostels ? hostels.length : (hostels.length > 2 ? 2 : hostels.length),
          separatorBuilder: (context, index) => const SizedBox(height: 0),
          itemBuilder: (context, index) {
            final hostel = hostels[index];
            final isNewlyRevealed = _showAllHostels && index >= 2;
            
            Widget child = HostelListRow(
              hostel: hostel,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.adminHostelMgmt,
                  arguments: hostel.hostelId,
                );
              },
              trailingBadge: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hostel.approved ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hostel.approved ? 'Approved' : 'Pending',
                  style: GoogleFonts.inter(
                    color: hostel.approved ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            );

            if (isNewlyRevealed) {
              return FadeInUp(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: (index - 2) * 50),
                child: child,
              );
            }
            return child;
          },
        ),
      ],
    );
  }
}
