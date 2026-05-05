import '../models/complaint_model.dart';
import '../../services/firestore_service.dart';
import '../../domain/enums/complaint_status.dart';

class ComplaintRepository {
  final FirestoreService _firestoreService;

  ComplaintRepository(this._firestoreService);

  // Get all complaints for a hostel
  Stream<List<ComplaintModel>> getComplaintsByHostel(String hostelId) {
    return _firestoreService.complaintsCollection
        .where('hostelId', isEqualTo: hostelId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromFirestore(doc))
            .toList());
  }

  // Get complaints by status
  Stream<List<ComplaintModel>> getComplaintsByStatus(
    String hostelId,
    ComplaintStatus status,
  ) {
    return _firestoreService.complaintsCollection
        .where('hostelId', isEqualTo: hostelId)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromFirestore(doc))
            .toList());
  }

  // Get complaints by resident (for student history)
  Stream<List<ComplaintModel>> getComplaintsByResident(String residentId) {
    return _firestoreService.complaintsCollection
        .where('residentId', isEqualTo: residentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromFirestore(doc))
            .toList());
  }

  // Get complaints by user ID (across all hostels)
  Stream<List<ComplaintModel>> getComplaintsByUserId(String userId) {
    return _firestoreService.complaintsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromFirestore(doc))
            .toList());
  }

  // Get complaint by ID
  Future<ComplaintModel?> getComplaintById(String complaintId) async {
    try {
      final doc = await _firestoreService.complaintsCollection.doc(complaintId).get();
      if (!doc.exists) return null;
      return ComplaintModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get complaint: $e');
    }
  }

  // Create complaint
  Future<String> createComplaint(ComplaintModel complaint) async {
    try {
      final docRef = await _firestoreService.complaintsCollection.add(complaint.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create complaint: $e');
    }
  }

  // Update complaint status
  Future<void> updateComplaintStatus(
    String complaintId,
    ComplaintStatus status, {
    String? adminNotes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
      };

      if (adminNotes != null) {
        updates['adminNotes'] = adminNotes;
      }

      if (status == ComplaintStatus.resolved) {
        updates['resolvedAt'] = DateTime.now();
      }

      await _firestoreService.complaintsCollection.doc(complaintId).update(updates);
    } catch (e) {
      throw Exception('Failed to update complaint: $e');
    }
  }

  // Update complaint with resolution timeframe (admin sets this)
  Future<void> setResolutionTimeframe(
    String complaintId, {
    required String estimatedTime,
    DateTime? estimatedDate,
    String? adminNotes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'estimatedResolutionTime': estimatedTime,
        'studentNotified': true,
        'status': ComplaintStatus.inProgress.name,
      };

      if (estimatedDate != null) {
        updates['estimatedResolutionDate'] = estimatedDate;
      }

      if (adminNotes != null) {
        updates['adminNotes'] = adminNotes;
      }

      await _firestoreService.complaintsCollection.doc(complaintId).update(updates);
    } catch (e) {
      throw Exception('Failed to set resolution timeframe: $e');
    }
  }

  // Update complaint
  Future<void> updateComplaint(String complaintId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.complaintsCollection.doc(complaintId).update(data);
    } catch (e) {
      throw Exception('Failed to update complaint: $e');
    }
  }

  // Delete complaint
  Future<void> deleteComplaint(String complaintId) async {
    try {
      await _firestoreService.complaintsCollection.doc(complaintId).delete();
    } catch (e) {
      throw Exception('Failed to delete complaint: $e');
    }
  }

  // Get pending complaints count for a hostel
  Future<int> getPendingComplaintsCount(String hostelId) async {
    try {
      final snapshot = await _firestoreService.complaintsCollection
          .where('hostelId', isEqualTo: hostelId)
          .where('status', whereIn: [ComplaintStatus.open.name, ComplaintStatus.inProgress.name])
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
