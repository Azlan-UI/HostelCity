import '../models/hostel_model.dart';
import '../models/review_model.dart';
import '../../services/firestore_service.dart';

class HostelRepository {
  final FirestoreService _firestoreService;

  HostelRepository(this._firestoreService);

  // Get all approved hostels
  Stream<List<HostelModel>> getApprovedHostels() {
    return _firestoreService.hostelsCollection
        .where('approved', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HostelModel.fromFirestore(doc))
            .toList());
  }

  // Get hostels by city
  Stream<List<HostelModel>> getHostelsByCity(String city) {
    return _firestoreService.hostelsCollection
        .where('approved', isEqualTo: true)
        .where('city', isEqualTo: city)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HostelModel.fromFirestore(doc))
            .toList());
  }

  // Get hostels by gender type
  Stream<List<HostelModel>> getHostelsByGender(String genderType) {
    return _firestoreService.hostelsCollection
        .where('approved', isEqualTo: true)
        .where('genderType', isEqualTo: genderType)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HostelModel.fromFirestore(doc))
            .toList());
  }

  // Get hostel by ID
  Future<HostelModel?> getHostelById(String hostelId) async {
    try {
      final doc = await _firestoreService.hostelsCollection.doc(hostelId).get();
      if (!doc.exists) return null;
      return HostelModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get hostel: $e');
    }
  }

  // Stream hostel by ID
  Stream<HostelModel?> streamHostelById(String hostelId) {
    return _firestoreService.hostelsCollection
        .doc(hostelId)
        .snapshots()
        .map((doc) => doc.exists ? HostelModel.fromFirestore(doc) : null);
  }

  // Create hostel
  Future<String> createHostel(HostelModel hostel) async {
    try {
      final docRef = await _firestoreService.hostelsCollection.add(hostel.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create hostel: $e');
    }
  }

  // Update hostel
  Future<void> updateHostel(String hostelId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.hostelsCollection.doc(hostelId).update(data);
    } catch (e) {
      throw Exception('Failed to update hostel: $e');
    }
  }

  // Update full hostel model (convenience method)
  Future<void> updateHostelFull(HostelModel hostel) async {
    try {
      await _firestoreService.hostelsCollection
          .doc(hostel.hostelId)
          .update(hostel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update hostel: $e');
    }
  }

  // Delete hostel
  Future<void> deleteHostel(String hostelId) async {
    try {
      await _firestoreService.hostelsCollection.doc(hostelId).delete();
    } catch (e) {
      throw Exception('Failed to delete hostel: $e');
    }
  }

  // Get hostels by admin
  Stream<List<HostelModel>> getHostelsByAdmin(String adminId) {
    return _firestoreService.hostelsCollection
        .where('adminId', isEqualTo: adminId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HostelModel.fromFirestore(doc))
            .toList());
  }

  // Get pending hostels (for platform admin)
  Stream<List<HostelModel>> getPendingHostels() {
    return _firestoreService.hostelsCollection
        .where('approved', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HostelModel.fromFirestore(doc))
            .toList());
  }

  // Approve hostel
  Future<void> approveHostel(String hostelId) async {
    try {
      await _firestoreService.hostelsCollection.doc(hostelId).update({
        'approved': true,
      });
    } catch (e) {
      throw Exception('Failed to approve hostel: $e');
    }
  }

  // Get reviews for hostel
  Stream<List<ReviewModel>> getHostelReviews(String hostelId) {
    return _firestoreService.reviewsCollection
        .where('hostelId', isEqualTo: hostelId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  // Add review
  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestoreService.reviewsCollection.add(review.toFirestore());
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Get average rating
  Future<double> getAverageRating(String hostelId) async {
    try {
      final snapshot = await _firestoreService.reviewsCollection
          .where('hostelId', isEqualTo: hostelId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      final totalRating = reviews.fold<double>(
        0.0,
        (acc, review) => acc + review.rating,
      );

      return totalRating / reviews.length;
    } catch (e) {
      return 0.0;
    }
  }
}
