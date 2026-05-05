import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/booking_model.dart';
import '../../providers/service_providers.dart';
import '../../widgets/common/app_drawer.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/payment/payment_gateway_dialog.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      drawer: const AppDrawer(),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, ref, user.uid),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, String userId) {
    final bookingsAsync = ref.watch(studentBookingsProvider(userId));

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.history,
            title: 'No Bookings Yet',
            message: 'Your hostel bookings and paid records will appear here.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(studentBookingsProvider(userId)),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 50),
                child: _BookingCard(booking: booking),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpired = booking.status == BookingStatus.pending && 
                     DateTime.now().isAfter(booking.expiresAt);
    
    final statusColor = _getStatusColor(isExpired ? BookingStatus.expired : booking.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.hostelName ?? 'Hostel',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        booking.hostelCity ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (isExpired ? 'EXPIRED' : booking.status.name).toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(context, Icons.bed, 'Room Type', '${booking.seaterType}-Seater'),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.calendar_today, 'Booked On', DateFormatter.formatDateTime(booking.createdAt)),
            if (booking.status == BookingStatus.pending && !isExpired) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Payment deadline: ${DateFormatter.getRelativeTime(booking.expiresAt).replaceAll(' ago', '')} left',
                        style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelBooking(context, ref),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _payNow(context, ref),
                      child: const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.paid: return AppColors.success;
      case BookingStatus.pending: return Colors.orange;
      case BookingStatus.canceled:
      case BookingStatus.expired: return AppColors.error;
    }
  }

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Cancel')),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(bookingRepositoryProvider).cancelBooking(booking.bookingId);
    }
  }

  Future<void> _payNow(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentGatewayDialog(booking: booking),
    );
  }
}

// Provider for bookings
final studentBookingsProvider = StreamProvider.family<List<BookingModel>, String>((ref, studentId) {
  return ref.watch(bookingRepositoryProvider).getStudentBookings(studentId);
});
