import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/hostel_model.dart';
import '../../providers/hostel_providers.dart';
import '../../providers/admin_providers.dart';
import 'admin_bookings_screen.dart';
import 'admin_residents_screen.dart';
import 'admin_complaints_screen.dart';
import 'admin_dues_settings_screen.dart';
import 'add_hostel_screen.dart';
import '../../widgets/common/stat_pill.dart';
import 'package:google_fonts/google_fonts.dart';


class AdminHostelManagementScreen extends ConsumerWidget {
  final String hostelId;

  const AdminHostelManagementScreen({
    super.key,
    required this.hostelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostelAsync = ref.watch(hostelByIdProvider(hostelId));

    return hostelAsync.when(
      data: (hostel) {
        if (hostel == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Hostel Management')),
            body: const Center(child: Text('Hostel not found')),
          );
        }

        return _buildManagementScreen(context, ref, hostel);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Hostel Management')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: const Text('Hostel Management')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildManagementScreen(BuildContext context, WidgetRef ref, HostelModel hostel) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hostel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Hostel',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.addHostel,
                arguments: hostel,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(hostelByIdProvider);
          ref.invalidate(activeResidentsCountProvider);
          ref.invalidate(pendingComplaintsCountProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context, hostel),
              const SizedBox(height: 24),
              _buildStatisticsSection(context, ref, hostel),
              const SizedBox(height: 24),
              _buildOccupancySection(context, hostel),
              const SizedBox(height: 24),
              _buildQuickActionsSection(context, ref, hostel),
              const SizedBox(height: 24),
              _buildRoomCategoriesSection(context, hostel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, HostelModel hostel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.home_work, size: 32, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hostel.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${hostel.area}, ${hostel.city}',
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hostel.approved
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hostel.approved ? 'APPROVED' : 'PENDING',
                  style: GoogleFonts.inter(
                    color: hostel.approved ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                Icons.person,
                hostel.genderType.name.toUpperCase(),
                AppColors.primary,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.phone,
                hostel.contactNumber,
                AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, WidgetRef ref, HostelModel hostel) {
    final residentsAsync = ref.watch(activeResidentsCountProvider(hostel.hostelId));
    final complaintsAsync = ref.watch(pendingComplaintsCountProvider(hostel.hostelId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
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
                label: 'Active Residents',
                value: residentsAsync.when(
                  data: (count) => count.toString(),
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
                icon: Icons.people,
                baseColor: AppColors.success,
              ),
              const SizedBox(width: 12),
              StatPill(
                label: 'Pending Issues',
                value: complaintsAsync.when(
                  data: (count) => count.toString(),
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
                icon: Icons.report_problem,
                baseColor: AppColors.warning,
              ),
              const SizedBox(width: 12),
              StatPill(
                label: 'Total Beds',
                value: (hostel.totalBeds ?? 0).toString(),
                icon: Icons.bed,
                baseColor: AppColors.primary,
              ),
              const SizedBox(width: 12),
              StatPill(
                label: 'Occupancy',
                value: '${hostel.occupancyRate.toStringAsFixed(0)}%',
                icon: Icons.show_chart,
                baseColor: AppColors.info,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOccupancySection(BuildContext context, HostelModel hostel) {
    final totalBeds = hostel.totalBeds ?? 0;
    final occupiedBeds = hostel.occupiedBeds ?? 0;
    final availableBeds = totalBeds - occupiedBeds;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Occupancy Overview',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (occupiedBeds > 0)
                Expanded(
                  flex: occupiedBeds,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.horizontal(
                        left: const Radius.circular(4),
                        right: availableBeds == 0 ? const Radius.circular(4) : Radius.zero,
                      ),
                    ),
                  ),
                ),
              if (availableBeds > 0)
                Expanded(
                  flex: availableBeds,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.horizontal(
                        right: const Radius.circular(4),
                        left: occupiedBeds == 0 ? const Radius.circular(4) : Radius.zero,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOccupancyStat('Occupied', occupiedBeds, AppColors.success),
              _buildOccupancyStat('Available', availableBeds, AppColors.textSecondary),
              _buildOccupancyStat('Total', totalBeds, AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref, HostelModel hostel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage',
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
              icon: Icons.assignment,
              title: 'Bookings',
              color: AppColors.primary,
              onTap: () => Navigator.pushNamed(
                context, 
                AppRouter.adminBookings, 
                arguments: {'hostelId': hostel.hostelId, 'hostelName': hostel.name},
              ),
            ),
            _buildActionChip(
              context,
              icon: Icons.people,
              title: 'Residents',
              color: AppColors.success,
              onTap: () => Navigator.pushNamed(
                context, 
                AppRouter.adminResidents, 
                arguments: hostel.hostelId,
              ),
            ),
            _buildActionChip(
              context,
              icon: Icons.report,
              title: 'Complaints',
              color: AppColors.warning,
              onTap: () => Navigator.pushNamed(
                context, 
                AppRouter.adminComplaints, 
                arguments: hostel.hostelId,
              ),
            ),
            _buildActionChip(
              context,
              icon: Icons.payments,
              title: 'Dues',
              color: AppColors.info,
              onTap: () => Navigator.pushNamed(
                context, 
                AppRouter.adminDuesSettings, 
                arguments: hostel.hostelId,
              ),
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

  Widget _buildRoomCategoriesSection(BuildContext context, HostelModel hostel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Categories',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...hostel.roomCategories.map((category) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.bed, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${category.seaterType}-Seater Room',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rs. ${category.rent.toInt()}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildCategoryInfo('Total', category.totalBeds.toString()),
                    const SizedBox(width: 24),
                    _buildCategoryInfo('Available', category.availableBeds.toString()),
                    const SizedBox(width: 24),
                    _buildCategoryInfo(
                      'Occupied',
                      (category.totalBeds - category.availableBeds).toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
