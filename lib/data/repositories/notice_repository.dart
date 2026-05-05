import '../models/notice_model.dart';
import '../../services/firestore_service.dart';
import '../../domain/enums/target_group.dart';

class NoticeRepository {
  final FirestoreService _firestoreService;

  NoticeRepository(this._firestoreService);

  // Get all notices for a hostel
  Stream<List<NoticeModel>> getNoticesByHostel(String hostelId) {
    return _firestoreService.noticesCollection
        .where('hostelId', isEqualTo: hostelId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoticeModel.fromFirestore(doc))
            .toList());
  }

  // Get notices by target group
  Stream<List<NoticeModel>> getNoticesByTargetGroup(
    String hostelId,
    TargetGroup targetGroup,
  ) {
    return _firestoreService.noticesCollection
        .where('hostelId', isEqualTo: hostelId)
        .where('targetGroup', isEqualTo: targetGroup.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoticeModel.fromFirestore(doc))
            .toList());
  }

  // Get notice by ID
  Future<NoticeModel?> getNoticeById(String noticeId) async {
    try {
      final doc = await _firestoreService.noticesCollection.doc(noticeId).get();
      if (!doc.exists) return null;
      return NoticeModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get notice: $e');
    }
  }

  // Create notice
  Future<String> createNotice(NoticeModel notice) async {
    try {
      final docRef = await _firestoreService.noticesCollection.add(notice.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notice: $e');
    }
  }

  // Update notice
  Future<void> updateNotice(String noticeId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.noticesCollection.doc(noticeId).update(data);
    } catch (e) {
      throw Exception('Failed to update notice: $e');
    }
  }

  // Delete notice
  Future<void> deleteNotice(String noticeId) async {
    try {
      await _firestoreService.noticesCollection.doc(noticeId).delete();
    } catch (e) {
      throw Exception('Failed to delete notice: $e');
    }
  }

  // Get recent notices (last 5)
  Future<List<NoticeModel>> getRecentNotices(String hostelId, {int limit = 5}) async {
    try {
      final snapshot = await _firestoreService.noticesCollection
          .where('hostelId', isEqualTo: hostelId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => NoticeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
