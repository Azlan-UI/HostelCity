import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/dues_model.dart';
import '../../providers/dues_providers.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/app_drawer.dart';
import '../../providers/auth_providers.dart';

class AdminDuesDashboardScreen extends ConsumerWidget {
  const AdminDuesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dues Management'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, ref, user.uid),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, String adminId) {
    final hostelsAsync = ref.watch(hostelsByAdminProvider(adminId));

    return hostelsAsync.when(
      data: (hostels) {
        if (hostels.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.home_work_outlined,
            title: 'No Hostels',
            message: 'Add a hostel to manage resident dues.',
          );
        }

        final hostelId = hostels.first.hostelId;
        final duesAsync = ref.watch(hostelDuesProvider(hostelId));

        return duesAsync.when(
          data: (dues) {
            if (dues.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.payments_outlined,
                title: 'No Dues Found',
                message: 'No resident dues have been generated or found.',
              );
            }

            final pending = dues.where((d) => d.status != DuesStatus.paid).toList();
            final paid = dues.where((d) => d.status == DuesStatus.paid).toList();

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Pending (${pending.length})'),
                      Tab(text: 'Paid (${paid.length})'),
                    ],
                    labelColor: AppColors.primary,
                    indicatorColor: AppColors.primary,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _DuesList(dues: pending, showActions: true),
                        _DuesList(dues: paid, showActions: false),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _DuesList extends StatelessWidget {
  final List<DuesModel> dues;
  final bool showActions;

  const _DuesList({required this.dues, required this.showActions});

  @override
  Widget build(BuildContext context) {
    if (dues.isEmpty) {
      return Center(
        child: Text(
          'No records found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dues.length,
      itemBuilder: (context, index) {
        final due = dues[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: _DuesListItem(due: due),
        );
      },
    );
  }
}

class _DuesListItem extends StatelessWidget {
  final DuesModel due;
  const _DuesListItem({required this.due});

  @override
  Widget build(BuildContext context) {
    final isOverdue = due.status == DuesStatus.overdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                due.studentName ?? 'Student',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            Text(
              'PKR ${due.totalAmount.toInt()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: due.status == DuesStatus.paid ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Month: ${due.month}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  due.status == DuesStatus.paid ? Icons.check_circle : Icons.pending_actions,
                  size: 14,
                  color: due.status == DuesStatus.paid ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  due.status.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: due.status == DuesStatus.paid ? AppColors.success : AppColors.warning,
                  ),
                ),
                if (isOverdue) ...[
                   const SizedBox(width: 8),
                   Text(
                     '(${due.daysOverdue} days late)',
                     style: TextStyle(color: AppColors.error, fontSize: 11),
                   ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to User Dues History
          Navigator.pushNamed(
            context,
            AppRouter.userDuesHistory,
            arguments: {
              'studentId': due.studentId,
              'studentName': due.studentName ?? 'Student',
            },
          );
        },
      ),
    );
  }
}