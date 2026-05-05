import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../domain/enums/verification_enums.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/booking_model.dart';
import '../models/resident_model.dart';
import '../models/dues_model.dart';
import '../../domain/enums/payment_status.dart';

class VerificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get users by verification status
  Stream<List<UserModel>> getUsersByVerificationStatus(VerificationStatus status) {
    Query query = _firestore.collection(FirebaseConstants.usersCollection);

    // For Approved/Rejected, we use the specific index query for efficiency
    // For Pending, we fetch ALL users to catch those with missing fields or case mismatches
    if (status != VerificationStatus.pending) {
      query = query.where('verificationStatus', isEqualTo: status.name);
    }

    return query.snapshots().map((snapshot) {
      final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      
      // Filter client-side
      final filteredUsers = users.where((user) {
        if (status == VerificationStatus.pending) {
          // Show user if status is explicitly pending OR if getting all (query didn't filter) and model defaulted to pending
          return user.verificationStatus == VerificationStatus.pending;
        }
        return true; // Query already filtered for approved/rejected
      }).toList();

      // Sort client-side (safe against missing createdAt)
      filteredUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return filteredUsers;
    });
  }

  // Update user verification
  Future<void> updateUserVerification({
    required String userId,
    required VerificationStatus status,
    String? rejectionReason,
  }) async {
    try {
      final updates = <String, dynamic>{
        'verificationStatus': status.name,
      };
      
      if (rejectionReason != null) {
        updates['verificationRejectionReason'] = rejectionReason;
      }

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update verification status: $e');
    }
  }

  // Get verification stats (simplified)
  Future<Map<String, int>> getVerificationStats() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .get();
      
      int pending = 0;
      int approved = 0;
      int rejected = 0;

      for (var doc in querySnapshot.docs) {
        final status = doc.data()['verificationStatus'];
        if (status == VerificationStatus.pending.name) {
          pending++;
        } else if (status == VerificationStatus.approved.name) {
          approved++;
        } else if (status == VerificationStatus.rejected.name) {
          rejected++;
        }
      }

      return {
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
      };
    } catch (e) {
      throw Exception('Failed to get verification stats: $e');
    }
  }

  // Migration: Approve all existing pending accounts
  Future<int> migrateExistingAccounts() async {
    final usersSnapshot = await _firestore.collection(FirebaseConstants.usersCollection).get();
    int updatedCount = 0;

    final batch = _firestore.batch();
    for (var doc in usersSnapshot.docs) {
      final status = doc.data()['verificationStatus'];
      if (status == null || status == VerificationStatus.pending.name) {
        batch.update(doc.reference, {
          'verificationStatus': VerificationStatus.approved.name,
          'migratedAt': FieldValue.serverTimestamp(),
        });
        updatedCount++;
      }
    }

    if (updatedCount > 0) {
      await batch.commit();
    }
    return updatedCount;
  }

  // Migration: Backfill Resident and Dues records for existing Paid bookings
  Future<Map<String, int>> migrateExistingBookings() async {
    int residentCreatedCount = 0;
    int duesCreatedCount = 0;
    int errorCount = 0;

    try {
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'paid')
          .get();

      for (var bookingDoc in bookingsSnapshot.docs) {
        try {
          final booking = BookingModel.fromFirestore(bookingDoc);
          
          // 1. Check if Resident Record exists
          final residentQuery = await _firestore
              .collection('residents')
              .where('bookingId', isEqualTo: booking.bookingId)
              .limit(1)
              .get();

          if (residentQuery.docs.isEmpty) {
            // Fetch User Details for Resident Record
            final userDoc = await _firestore.collection('users').doc(booking.studentId).get();
            final userData = userDoc.data();
            
            if (userData != null) {
              final resident = ResidentModel(
                residentId: '', // Firebase id
                userId: booking.studentId,
                hostelId: booking.hostelId,
                roomId: 'Allocated (Migrated)', 
                bedId: 'Allocated (Migrated)',
                bookingId: booking.bookingId,
                moveInDate: booking.createdAt,
                isActive: true,
                userName: userData['name'] ?? 'User',
                userEmail: userData['email'] ?? '',
                userPhone: userData['phone'] ?? '',
              );

              final resRef = _firestore.collection('residents').doc();
              await resRef.set(resident.toFirestore());
              residentCreatedCount++;

              // 2. Check and Create Dues Record for current month if missing
              final now = DateTime.now();
              final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
              
              final duesQuery = await _firestore
                  .collection('dues')
                  .where('bookingId', isEqualTo: booking.bookingId)
                  .where('month', isEqualTo: monthStr)
                  .limit(1)
                  .get();

              if (duesQuery.docs.isEmpty) {
                final dues = DuesModel(
                  duesId: '',
                  studentId: booking.studentId,
                  hostelId: booking.hostelId,
                  bookingId: booking.bookingId,
                  month: monthStr,
                  rentAmount: booking.rent,
                  totalAmount: booking.rent,
                  dueDate: booking.createdAt,
                  paidDate: booking.createdAt,
                  status: DuesStatus.paid,
                  createdAt: booking.createdAt,
                  studentName: userData['name'] ?? 'User',
                  hostelName: booking.hostelName,
                  fineAmount: 0,
                );
                
                final duesRef = _firestore.collection('dues').doc();
                await duesRef.set(dues.toFirestore());
                duesCreatedCount++;
              }
            }
          }
        } catch (e) {
          print('Error migrating booking ${bookingDoc.id}: $e');
          errorCount++;
        }
      }

      return {
        'residentsCreated': residentCreatedCount,
        'duesCreated': duesCreatedCount,
        'errors': errorCount,
      };
    } catch (e) {
      throw Exception('Migration failed: $e');
    }
  }
}
