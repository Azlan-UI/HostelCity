import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/booking_model.dart';
import '../../providers/service_providers.dart';
import '../../widgets/common/empty_state_widget.dart';


class AdminBookingsScreen extends ConsumerWidget {
  final String hostelId;
  final String hostelName;

  const AdminBookingsScreen({
    super.key,
    required this.hostelId,
    required this.hostelName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(hostelBookingsProvider(hostelId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings: $hostelName'),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.assignment,
              title: 'No Bookings Yet',
              message: 'When students book rooms in this hostel, they will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 50),
                child: _AdminBookingCard(booking: booking),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AdminBookingCard extends StatelessWidget {
  final BookingModel booking;
  const _AdminBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isExpired = booking.status == BookingStatus.pending && 
                     DateTime.now().isAfter(booking.expiresAt);
    
    final statusColor = _getStatusColor(isExpired ? BookingStatus.expired : booking.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${booking.seaterType}-Seater Room',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (isExpired ? 'EXPIRED' : booking.status.name).toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(context, Icons.person, 'Student ID', booking.studentId),
            _buildInfoRow(context, Icons.calendar_today, 'Booked On', DateFormatter.formatDateTime(booking.createdAt)),
            if (booking.status == BookingStatus.pending && !isExpired)
              _buildInfoRow(context, Icons.timer, 'Deadline', DateFormatter.formatDateTime(booking.expiresAt), color: AppColors.warning),
            _buildInfoRow(context, Icons.payments, 'Rent', '${booking.rent.toInt()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.textTertiary),
          const SizedBox(width: 8),
          Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.paid: return AppColors.success;
      case BookingStatus.pending: return AppColors.warning;
      case BookingStatus.canceled:
      case BookingStatus.expired: return AppColors.error;
    }
  }
}

// Provider for hostel bookings
final hostelBookingsProvider = StreamProvider.family<List<BookingModel>, String>((ref, hostelId) {
  return ref.watch(bookingRepositoryProvider).getHostelBookings(hostelId);
});
