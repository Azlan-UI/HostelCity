import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/dues_model.dart';
import '../../providers/dues_providers.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/app_drawer.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/payment/dues_payment_dialog.dart';

class StudentDuesScreen extends ConsumerWidget {
  const StudentDuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dues'),
      ),
      drawer: const AppDrawer(),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, ref, user.uid),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, String userId) {
    final duesAsync = ref.watch(studentDuesProvider(userId));

    return duesAsync.when(
      data: (dues) {
        if (dues.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.check_circle_outline,
            title: 'No Dues',
            message: 'You have no pending or past dues.',
          );
        }

        final pendingDues = dues.where((d) => d.status == DuesStatus.pending || d.status == DuesStatus.overdue).toList();
        final paidDues = dues.where((d) => d.status == DuesStatus.paid).toList();

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(studentDuesProvider(userId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pendingDues.isNotEmpty) ...[
                  Text(
                    'Outstanding Dues',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...pendingDues.asMap().entries.map((entry) {
                    return FadeInUp(
                      delay: Duration(milliseconds: entry.key * 50),
                      child: _buildDuesCard(context, entry.value, isOutstanding: true),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
                if (paidDues.isNotEmpty) ...[
                  Text(
                    'Payment History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...paidDues.asMap().entries.map((entry) {
                    return FadeInUp(
                      delay: Duration(milliseconds: entry.key * 50),
                      child: _buildDuesCard(context, entry.value, isOutstanding: false),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildDuesCard(BuildContext context, DuesModel due, {required bool isOutstanding}) {
    final statusColor = _getStatusColor(due.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Month: ${due.month}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (due.hostelName != null)
                        Text(
                          due.hostelName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    due.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rent'),
                Text('PKR ${due.rentAmount.toStringAsFixed(0)}'),
              ],
            ),
            if (due.fineAmount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fine', style: TextStyle(color: AppColors.error)),
                  Text('PKR ${due.fineAmount.toStringAsFixed(0)}', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ],
            if (due.isOverdue && due.fineAmount == 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overdue', style: TextStyle(color: AppColors.error)),
                  Text('${due.daysOverdue} days', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'PKR ${due.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isOutstanding ? AppColors.error : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Due: ${DateFormatter.formatDate(due.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (due.paidDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.check_circle, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'Paid: ${DateFormatter.formatDate(due.paidDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                        ),
                  ),
                ],
              ],
            ),
            if (due.status != DuesStatus.paid) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => DuesPaymentDialog(dues: due),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Pay Now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DuesStatus status) {
    switch (status) {
      case DuesStatus.pending:
        return Colors.orange;
      case DuesStatus.paid:
        return AppColors.success;
      case DuesStatus.overdue:
        return AppColors.error;
    }
  }
}
