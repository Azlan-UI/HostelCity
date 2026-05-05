import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dues_model.dart';
import '../models/resident_model.dart';
import '../models/booking_model.dart';

class DuesRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'dues';

  DuesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create a new dues entry
  Future<DuesModel> createDues(DuesModel dues) async {
    final docRef = _firestore.collection(_collection).doc();
    final newDues = dues.copyWith(duesId: docRef.id);
    await docRef.set(newDues.toFirestore());
    return newDues;
  }

  // Get all dues for a student
  Stream<List<DuesModel>> getStudentDues(String studentId) {
    return _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DuesModel.fromFirestore(doc)).toList());
  }

  // Get all dues for a hostel
  Stream<List<DuesModel>> getHostelDues(String hostelId) {
    return _firestore
        .collection(_collection)
        .where('hostelId', isEqualTo: hostelId)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DuesModel.fromFirestore(doc)).toList());
  }

  // Get overdue dues for a hostel
  Stream<List<DuesModel>> getOverdueDues(String hostelId) {
    return _firestore
        .collection(_collection)
        .where('hostelId', isEqualTo: hostelId)
        .where('status', isEqualTo: DuesStatus.overdue.name)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DuesModel.fromFirestore(doc)).toList());
  }

  // Update dues status (e.g., mark as paid)
  Future<void> updateDuesStatus(String duesId, DuesStatus status, {double? fineAmount}) async {
    final updates = <String, dynamic>{
      'status': status.name,
    };
    if (status == DuesStatus.paid) {
      updates['paidDate'] = Timestamp.fromDate(DateTime.now());
    }
    if (fineAmount != null) {
      updates['fineAmount'] = fineAmount;
      // Recalculate total
      final doc = await _firestore.collection(_collection).doc(duesId).get();
      if (doc.exists) {
        final dues = DuesModel.fromFirestore(doc);
        updates['totalAmount'] = dues.rentAmount + fineAmount;
      }
    }
    await _firestore.collection(_collection).doc(duesId).update(updates);
  }

  // Generate monthly dues for a booking
  Future<void> generateMonthlyDues({
    required String studentId,
    required String hostelId,
    required String bookingId,
    required double rentAmount,
    required int deadlineDays,
    required String month,
    String? studentName,
    String? hostelName,
  }) async {
    // Check if dues already exist for this month
    final existing = await _firestore
        .collection(_collection)
        .where('bookingId', isEqualTo: bookingId)
        .where('month', isEqualTo: month)
        .get();

    if (existing.docs.isNotEmpty) return; // Already generated

    final now = DateTime.now();
    final year = int.parse(month.split('-')[0]);
    final mon = int.parse(month.split('-')[1]);
    final dueDate = DateTime(year, mon, deadlineDays);

    final dues = DuesModel(
      duesId: '',
      studentId: studentId,
      hostelId: hostelId,
      bookingId: bookingId,
      month: month,
      rentAmount: rentAmount,
      totalAmount: rentAmount,
      dueDate: dueDate,
      status: now.isAfter(dueDate) ? DuesStatus.overdue : DuesStatus.pending,
      createdAt: now,
      studentName: studentName,
      hostelName: hostelName,
    );

    await createDues(dues);
  }

  // Generate dues for all active residents in a hostel for the current month
  Future<int> generateHostelDues(String hostelId, int rentDeadlineDays) async {
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    int generatedCount = 0;

    // 1. Get active residents
    final residentsSnap = await _firestore
        .collection('residents')
        .where('hostelId', isEqualTo: hostelId)
        .where('isActive', isEqualTo: true)
        .get();

    for (var doc in residentsSnap.docs) {
      final resident = ResidentModel.fromFirestore(doc);
      if (resident.bookingId == null) continue;

      // 2. Check if dues exist for this month
      final duesSnap = await _firestore
          .collection(_collection)
          .where('bookingId', isEqualTo: resident.bookingId)
          .where('month', isEqualTo: monthStr)
          .limit(1)
          .get();

      if (duesSnap.docs.isNotEmpty) continue;

      // 3. Fetch Booking for rent amount
      final bookingDoc = await _firestore.collection('bookings').doc(resident.bookingId).get();
      if (!bookingDoc.exists) continue;
      final booking = BookingModel.fromFirestore(bookingDoc);

      // 4. Create Dues
      // Handle edge case where deadline day > days in month
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      final effectiveDeadline = rentDeadlineDays > lastDayOfMonth ? lastDayOfMonth : rentDeadlineDays;
      final dueDate = DateTime(now.year, now.month, effectiveDeadline);
      
      final dues = DuesModel(
        duesId: '',
        studentId: resident.userId,
        hostelId: hostelId,
        bookingId: resident.bookingId!,
        month: monthStr,
        rentAmount: booking.rent,
        totalAmount: booking.rent,
        dueDate: dueDate,
        status: now.isAfter(dueDate) ? DuesStatus.overdue : DuesStatus.pending,
        createdAt: now,
        studentName: resident.userName,
        hostelName: booking.hostelName,
        fineAmount: 0,
      );

      await createDues(dues);
      generatedCount++;
    }
    return generatedCount;
  }
}
