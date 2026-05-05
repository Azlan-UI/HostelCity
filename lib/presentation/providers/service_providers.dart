import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/fcm_service.dart';
import '../../services/location_service.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/payment_repository.dart';


// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Booking Repository Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(firestoreServiceProvider).firestore);
});

// Payment Repository Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(firestoreServiceProvider).firestore);
});

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// FCM Service Provider
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

// Location Service Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
