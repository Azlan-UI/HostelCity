import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/dues_model.dart';
import '../../providers/dues_providers.dart';
import '../../providers/hostel_providers.dart';
import '../../widgets/common/auth_gate.dart';
import '../../widgets/common/empty_state_widget.dart';

class AdminDuesScreen extends ConsumerStatefulWidget {
  final String hostelId;
  final String hostelName;

  const AdminDuesScreen({
    super.key,
    required this.hostelId,
    required this.hostelName,
  });

  @override
  ConsumerState<AdminDuesScreen> createState() => _AdminDuesScreenState();
}

class _AdminDuesScreenState extends ConsumerState<AdminDuesScreen> {
  DuesStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final duesAsync = ref.watch(hostelDuesProvider(widget.hostelId));
    final hostelAsync = ref.watch(hostelByIdProvider(widget.hostelId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hostelName} - Dues'),
        actions: [
          PopupMenuButton<dynamic>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'filter') {
                // ... handle filter selection if needed, but current implementation uses separate logic
              } else if (value is DuesStatus?) {
                setState(() => _filterStatus = value);
              } else if (value == 'generate') {
                final hostel = hostelAsync.value;
                if (hostel == null) return;
                
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Generate Monthly Dues'),
                    content: Text(
                      'This will generate dues for the current month for all active residents in ${hostel.name} who do not have them yet.\n\nDeadline: Day ${hostel.rentDeadlineDays} of this month.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Generate')),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating dues...')),
                    );
                    
                    final count = await ref.read(duesRepositoryProvider)
                        .generateHostelDues(widget.hostelId, hostel.rentDeadlineDays);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Generated $count new dues records.')),
                      );
                      ref.invalidate(hostelDuesProvider(widget.hostelId));
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate',
                child: Row(
                  children: [
                    Icon(Icons.autorenew, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Generate Monthly Dues'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(enabled: false, child: Text('Filter By Status')),
              const PopupMenuItem(value: null, child: Text('All')),
              ...DuesStatus.values.map((s) => PopupMenuItem(
                    value: s,
                    child: Text(s.name.toUpperCase()),
                  )),
            ],
          ),
        ],
      ),
      body: duesAsync.when(
        data: (dues) {
          final filtered = _filterStatus == null
              ? dues
              : dues.where((d) => d.status == _filterStatus).toList();

          if (filtered.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.payments_outlined,
              title: 'No Dues',
              message: 'No dues records found.',
            );
          }

          final dailyFine = hostelAsync.whenOrNull(data: (h) => h?.dailyFineAmount) ?? 0.0;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(hostelDuesProvider(widget.hostelId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final due = filtered[index];
                return FadeInUp(
                  delay: Duration(milliseconds: index * 50),
                  child: _buildDuesCard(context, due, dailyFine),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDuesCard(BuildContext context, DuesModel due, double dailyFine) {
    final statusColor = due.status == DuesStatus.paid 
        ? AppColors.success 
        : due.isOverdue 
            ? AppColors.error 
            : AppColors.warning;
            
    final currentFine = due.calculatedFine(dailyFine);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
          top: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: InkWell(
        onTap: () => _showDuesActions(context, due, dailyFine),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          due.studentName ?? 'Unknown Student',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Month: ${due.month}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
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
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAmountChip('Rent', 'PKR ${due.rentAmount.toStringAsFixed(0)}', AppColors.primary),
                  const SizedBox(width: 8),
                  if (due.isOverdue && currentFine > 0)
                    _buildAmountChip('Fine', 'PKR ${currentFine.toStringAsFixed(0)}', AppColors.error),
                  const Spacer(),
                  Text(
                    'PKR ${(due.rentAmount + currentFine).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: due.isOverdue ? AppColors.error : AppColors.primary,
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
                  if (due.isOverdue) ...[
                    const SizedBox(width: 12),
                    Text(
                      '${due.daysOverdue} days overdue',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountChip(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $amount',
        style: GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showDuesActions(BuildContext context, DuesModel due, double dailyFine) {
    if (due.status == DuesStatus.paid) return;

    final currentFine = due.calculatedFine(dailyFine);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mark as Paid',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${due.studentName ?? "Student"} - ${due.month}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rent:'),
                Text('PKR ${due.rentAmount.toStringAsFixed(0)}'),
              ],
            ),
            if (currentFine > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fine (${due.daysOverdue} days):', style: TextStyle(color: AppColors.error)),
                  Text('PKR ${currentFine.toStringAsFixed(0)}', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  'PKR ${(due.rentAmount + currentFine).toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final repo = ref.read(duesRepositoryProvider);
                    await repo.updateDuesStatus(
                      due.duesId,
                      DuesStatus.paid,
                      fineAmount: currentFine,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dues marked as paid')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: const Text('Confirm Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DuesStatus status) {
    switch (status) {
      case DuesStatus.pending:
        return AppColors.warning;
      case DuesStatus.paid:
        return AppColors.success;
      case DuesStatus.overdue:
        return AppColors.error;
    }
  }
}
