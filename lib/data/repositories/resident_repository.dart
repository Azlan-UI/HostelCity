import '../models/resident_model.dart';
import '../../services/firestore_service.dart';

class ResidentRepository {
  final FirestoreService _firestoreService;

  ResidentRepository(this._firestoreService);

  // Get all residents for a hostel
  Stream<List<ResidentModel>> getResidentsByHostel(String hostelId) {
    return _firestoreService.residentsCollection
        .where('hostelId', isEqualTo: hostelId)
        .orderBy('moveInDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResidentModel.fromFirestore(doc))
            .toList());
  }

  // Get active residents for a hostel
  Stream<List<ResidentModel>> getActiveResidentsByHostel(String hostelId) {
    return _firestoreService.residentsCollection
        .where('hostelId', isEqualTo: hostelId)
        .where('isActive', isEqualTo: true)
        .orderBy('moveInDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResidentModel.fromFirestore(doc))
            .toList());
  }

  // Get resident by user ID (active only)
  Stream<ResidentModel?> getResidentByUserId(String userId) {
    return _firestoreService.residentsCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
            ? ResidentModel.fromFirestore(snapshot.docs.first)
            : null);
  }

  // Get all active residents for a user (multiple stays support)
  Stream<List<ResidentModel>> getAllResidentsByUserId(String userId) {
    return _firestoreService.residentsCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResidentModel.fromFirestore(doc))
            .toList());
  }

  // Get resident by ID
  Future<ResidentModel?> getResidentById(String residentId) async {
    try {
      final doc = await _firestoreService.residentsCollection.doc(residentId).get();
      if (!doc.exists) return null;
      return ResidentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get resident: $e');
    }
  }

  // Create resident
  Future<String> createResident(ResidentModel resident) async {
    try {
      final docRef = await _firestoreService.residentsCollection.add(resident.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create resident: $e');
    }
  }

  // Update resident
  Future<void> updateResident(String residentId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.residentsCollection.doc(residentId).update(data);
    } catch (e) {
      throw Exception('Failed to update resident: $e');
    }
  }

  // Mark resident as moved out
  Future<void> markResidentMovedOut(String residentId) async {
    try {
      await _firestoreService.residentsCollection.doc(residentId).update({
        'isActive': false,
        'moveOutDate': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to mark resident as moved out: $e');
    }
  }

  // Delete resident
  Future<void> deleteResident(String residentId) async {
    try {
      await _firestoreService.residentsCollection.doc(residentId).delete();
    } catch (e) {
      throw Exception('Failed to delete resident: $e');
    }
  }

  // Get active residents count for a hostel
  Future<int> getActiveResidentsCount(String hostelId) async {
    try {
      final snapshot = await _firestoreService.residentsCollection
          .where('hostelId', isEqualTo: hostelId)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Get residents by room
  Stream<List<ResidentModel>> getResidentsByRoom(String roomId) {
    return _firestoreService.residentsCollection
        .where('roomId', isEqualTo: roomId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ResidentModel.fromFirestore(doc))
            .toList());
  }
}
