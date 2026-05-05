import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/hostel_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'bookings';

  BookingRepository(this._firestore);

  // Check availability before booking
  Future<bool> checkAvailability(String hostelId, int seaterType) async {
    final hostelDoc = await _firestore.collection('hostels').doc(hostelId).get();
    if (!hostelDoc.exists) return false;

    final hostel = HostelModel.fromFirestore(hostelDoc);
    final category = hostel.roomCategories.firstWhere(
      (c) => c.seaterType == seaterType,
      orElse: () => throw Exception('Room category not found'),
    );

    return category.availableBeds > 0;
  }

  // Create a pending booking
  Future<BookingModel> createBooking(BookingModel booking) async {
    final isAvailable = await checkAvailability(booking.hostelId, booking.seaterType);
    if (!isAvailable) {
      throw Exception('Sorry, no beds available for this room type.');
    }

    final docRef = _firestore.collection(_collection).doc();
    final newBooking = BookingModel(
      bookingId: docRef.id,
      studentId: booking.studentId,
      hostelId: booking.hostelId,
      seaterType: booking.seaterType,
      rent: booking.rent,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
      hostelName: booking.hostelName,
      hostelCity: booking.hostelCity,
    );

    await docRef.set(newBooking.toFirestore());
    return newBooking;
  }

  // Stream of bookings for a student
  Stream<List<BookingModel>> getStudentBookings(String studentId) {
    return _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Stream of bookings for a hostel (for Admin)
  Stream<List<BookingModel>> getHostelBookings(String hostelId) {
    return _firestore
        .collection(_collection)
        .where('hostelId', isEqualTo: hostelId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection(_collection).doc(bookingId).update({
      'status': BookingStatus.canceled.name,
    });
  }

  // Cron-like check for expired bookings (can be called on app start or dashboard build)
  Future<void> cleanExpiredBookings() async {
    final now = DateTime.now();
    final expiredSnap = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: BookingStatus.pending.name)
        .where('expiresAt', isLessThan: Timestamp.fromDate(now))
        .get();

    final batch = _firestore.batch();
    for (var doc in expiredSnap.docs) {
      batch.update(doc.reference, {'status': BookingStatus.expired.name});
    }
    await batch.commit();
  }
}
