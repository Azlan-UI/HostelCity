import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/dues_model.dart';
import '../providers/auth_providers.dart';
import '../providers/service_providers.dart';
import '../providers/dues_providers.dart';
import '../screens/student/my_bookings_screen.dart'; // For studentBookingsProvider

final pendingBookingsBadgeProvider = Provider<int>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return 0;

  final bookingsAsync = ref.watch(studentBookingsProvider(user.userId));
  return bookingsAsync.when(
    data: (bookings) {
      return bookings.where((b) {
        final isExpired = b.status == BookingStatus.pending && 
                     DateTime.now().isAfter(b.expiresAt);
        return b.status == BookingStatus.pending && !isExpired;
      }).length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final dueDuesBadgeProvider = Provider<int>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return 0;

  final duesAsync = ref.watch(studentDuesProvider(user.userId));
  return duesAsync.when(
    data: (dues) {
      return dues.where((d) => d.status == DuesStatus.pending || d.status == DuesStatus.overdue).length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});
