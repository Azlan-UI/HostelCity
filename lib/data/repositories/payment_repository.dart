import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../models/booking_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'payments';

  PaymentRepository(this._firestore);

  // Record a new payment and update booking status
  Future<void> processPayment(PaymentModel payment) async {
    final batch = _firestore.batch();

    // 1. Record Payment
    final paymentDoc = _firestore.collection(_collection).doc();
    batch.set(paymentDoc, payment.toFirestore());

    // 2. Update Booking Status
    if (payment.bookingId != null) {
      final bookingRef = _firestore.collection('bookings').doc(payment.bookingId);
      batch.update(bookingRef, {
        'status': BookingStatus.paid.name,
      });

      // 3. Update Hostel Capacity
      final bookingSnap = await bookingRef.get();
      if (bookingSnap.exists) {
        final booking = BookingModel.fromFirestore(bookingSnap);
        final hostelRef = _firestore.collection('hostels').doc(booking.hostelId);
        
        final hostelSnap = await hostelRef.get();
        if (hostelSnap.exists) {
          final data = hostelSnap.data() as Map<String, dynamic>;
          final categories = (data['roomCategories'] as List).map((item) {
            final cat = Map<String, dynamic>.from(item);
            if (cat['seaterType'] == booking.seaterType) {
              cat['availableBeds'] = (cat['availableBeds'] ?? 0) - 1;
            }
            return cat;
          }).toList();

          batch.update(hostelRef, {
            'roomCategories': categories,
            'occupiedBeds': FieldValue.increment(1),
          });
        }
      }
    }

    await batch.commit();
  }

  // Stream of payments for a user
  Stream<List<PaymentModel>> getUserPayments(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromFirestore(doc))
            .toList());
  }
}
