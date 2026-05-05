import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/dues_model.dart';
import '../../providers/dues_providers.dart';
import '../../widgets/common/empty_state_widget.dart';


class UserDuesHistoryScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;

  const UserDuesHistoryScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duesAsync = ref.watch(studentDuesProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$studentName\'s History'),
      ),
      body: duesAsync.when(
        data: (dues) {
          if (dues.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history,
              title: 'No History',
              message: 'This user has no payment records yet.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dues.length,
            itemBuilder: (context, index) {
              final due = dues[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 50),
                child: _HistoryItem(due: due),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final DuesModel due;
  const _HistoryItem({required this.due});

  @override
  Widget build(BuildContext context) {
    final isPaid = due.status == DuesStatus.paid;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Row(
          children: [
            Text(due.month, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(
              'PKR ${due.totalAmount.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPaid ? Icons.check_circle : Icons.pending,
                  size: 14,
                  color: isPaid ? AppColors.success : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  due.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? AppColors.success : Colors.orange,
                  ),
                ),
              ],
            ),
            if (isPaid && due.paidDate != null)
              Text(
                'Paid on: ${DateFormatter.formatDate(due.paidDate!)}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }
}
