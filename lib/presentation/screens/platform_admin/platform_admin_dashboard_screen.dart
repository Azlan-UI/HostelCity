import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/hostel_model.dart';
import '../../providers/hostel_providers.dart';
import '../../providers/verification_providers.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/stat_pill.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/hostel/hostel_list_row.dart';

class PlatformAdminDashboardScreen extends ConsumerStatefulWidget {
  const PlatformAdminDashboardScreen({super.key});

  @override
  ConsumerState<PlatformAdminDashboardScreen> createState() => _PlatformAdminDashboardScreenState();
}

class _PlatformAdminDashboardScreenState extends ConsumerState<PlatformAdminDashboardScreen> {
  bool _showAllActiveHostels = false;
  bool _showAllPendingHostels = false;

  void _openHostelDetail(BuildContext context, String hostelId) {
    Navigator.pushNamed(
      context,
      AppRouter.hostelDetail,
      arguments: {'hostelId': hostelId, 'hideBooking': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingHostelsAsync = ref.watch(pendingHostelsProvider);
    final allHostelsAsync = ref.watch(approvedHostelsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Platform Admin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingHostelsProvider);
          ref.invalidate(approvedHostelsProvider);
          ref.invalidate(pendingVerificationsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 32),
              _buildStatisticsSection(context, ref, allHostelsAsync, pendingHostelsAsync),
              const SizedBox(height: 32),
              _buildVerificationQuickAction(context, ref),
              const SizedBox(height: 32),
              _buildPendingApprovalsSection(context, ref, pendingHostelsAsync),
              const SizedBox(height: 32),
              _buildAllHostelsSection(context, allHostelsAsync),
              const SizedBox(height: 48),
              _buildMigrationSection(context, ref),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationQuickAction(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingVerificationsProvider).value?.length ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRouter.verificationDashboard);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Verifications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Manual and automated identity logs',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$pendingCount New',
                      style: GoogleFonts.inter(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: AppColors.textTertiary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform Control',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'System monitoring and hostel oversight',
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
    AsyncValue<List<HostelModel>> allHostelsAsync,
    AsyncValue<List<HostelModel>> pendingHostelsAsync,
  ) {
    final approvedCount = allHostelsAsync.value?.length ?? 0;
    final pendingCount = pendingHostelsAsync.value?.length ?? 0;
    final verifCount = ref.watch(pendingVerificationsProvider).value?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              StatPill(
                label: 'Total Hostels',
                value: (approvedCount + pendingCount).toString(),
                icon: Icons.apartment_rounded,
                baseColor: AppColors.primary,
              ),
              const SizedBox(width: 12),
              StatPill(
                label: 'Pending Approval',
                value: pendingCount.toString(),
                icon: Icons.hourglass_empty_rounded,
                baseColor: AppColors.warning,
              ),
              const SizedBox(width: 12),
              StatPill(
                label: 'User Verification',
                value: verifCount.toString(),
                icon: Icons.shield_outlined,
                baseColor: AppColors.info,
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildPendingApprovalsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<HostelModel>> pendingHostelsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Pending Approvals',
          actionLabel: (pendingHostelsAsync.value != null && pendingHostelsAsync.value!.length > 2) 
            ? (_showAllPendingHostels ? 'See Less' : 'See More') 
            : null,
          onAction: () {
            setState(() {
              _showAllPendingHostels = !_showAllPendingHostels;
            });
          },
        ),
        const SizedBox(height: 12),
        pendingHostelsAsync.when(
          data: (hostels) {
            if (hostels.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No pending approvals',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final visibleHostels = _showAllPendingHostels ? hostels : hostels.take(2).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleHostels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final hostel = visibleHostels[index];
                final isNewlyRevealed = _showAllPendingHostels && index >= 2;
                
                Widget child = _buildPendingHostelCard(context, ref, hostel);
                
                if (isNewlyRevealed) {
                  return FadeInUp(
                    key: ValueKey('pending_${hostel.hostelId}'),
                    duration: const Duration(milliseconds: 300),
                    delay: Duration(milliseconds: (index - 2) * 50),
                    child: child,
                  );
                }
                return child;
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }

  Widget _buildPendingHostelCard(BuildContext context, WidgetRef ref, HostelModel hostel) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openHostelDetail(context, hostel.hostelId),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hostel.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hostel.city}, ${hostel.area}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.bed_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Beds: ${hostel.totalBeds ?? 0}',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              Icon(Icons.payments_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'PKR ${hostel.minRent.toInt()}',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reject Hostel'),
                        content: Text('Are you sure you want to reject "${hostel.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      // TODO: Implement reject functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reject functionality coming soon')),
                      );
                    }
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final repository = ref.read(hostelRepositoryProvider);
                      await repository.approveHostel(hostel.hostelId);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${hostel.name} approved successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
        ),
      ),
    );
  }

  Widget _buildAllHostelsSection(BuildContext context, AsyncValue<List<HostelModel>> allHostelsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Active Hostels',
          actionLabel: (allHostelsAsync.value != null && allHostelsAsync.value!.length > 2) 
            ? (_showAllActiveHostels ? 'See Less' : 'See More') 
            : null,
          onAction: () {
            setState(() {
              _showAllActiveHostels = !_showAllActiveHostels;
            });
          },
        ),
        const SizedBox(height: 12),
        allHostelsAsync.when(
          data: (hostels) {
            if (hostels.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    'No approved hostels yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              );
            }

            final visibleHostels = _showAllActiveHostels ? hostels : hostels.take(2).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleHostels.length,
              itemBuilder: (context, index) {
                final hostel = visibleHostels[index];
                final isNewlyRevealed = _showAllActiveHostels && index >= 2;
                
                Widget child = HostelListRow(
                  hostel: hostel,
                  onTap: () => _openHostelDetail(context, hostel.hostelId),
                );

                if (isNewlyRevealed) {
                  return FadeInUp(
                    key: ValueKey('active_${hostel.hostelId}'),
                    duration: const Duration(milliseconds: 300),
                    delay: Duration(milliseconds: (index - 2) * 50),
                    child: child,
                  );
                }
                return child;
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }

  Widget _buildMigrationSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'System Migration & Tools',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildMigrationTile(
                context,
                icon: Icons.verified_user,
                title: 'Verify All Accounts',
                subtitle: 'Approves all pending user accounts',
                onTap: () => _handleVerificationMigration(context, ref),
              ),
              const SizedBox(height: 12),
              _buildMigrationTile(
                context,
                icon: Icons.history,
                title: 'Backfill Booking Data',
                subtitle: 'Creates residents for existing bookings',
                onTap: () => _handleBookingMigration(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMigrationTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.border)),
    );
  }

  Future<void> _handleVerificationMigration(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showConfirmDialog(context, 'Verify All Accounts', 'This will approve all currently pending user accounts. Proceed?');
    if (confirmed != true) return;

    try {
      final repository = ref.read(verificationRepositoryProvider);
      final count = await repository.migrateExistingAccounts();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Migration Complete: $count users approved.')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _handleBookingMigration(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showConfirmDialog(context, 'Backfill Booking Data', 'This will create Resident records for all existing paid bookings. Proceed?');
    if (confirmed != true) return;

    try {
      final repository = ref.read(verificationRepositoryProvider);
      final results = await repository.migrateExistingBookings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Migration Complete! Created: ${results['residentsCreated']} residents, ${results['duesCreated']} dues.'),
        ));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Proceed')),
        ],
      ),
    );
  }
}