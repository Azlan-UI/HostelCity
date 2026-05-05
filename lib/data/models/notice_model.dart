import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/target_group.dart';

class NoticeModel {
  final String noticeId;
  final String hostelId;
  final String title;
  final String content;
  final TargetGroup targetGroup;
  final String? targetValue; // floor number or room ID
  final DateTime createdAt;
  final String createdBy;
  final String? createdByName;

  NoticeModel({
    required this.noticeId,
    required this.hostelId,
    required this.title,
    required this.content,
    required this.targetGroup,
    this.targetValue,
    required this.createdAt,
    required this.createdBy,
    this.createdByName,
  });

  // From Firestore
  factory NoticeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoticeModel(
      noticeId: doc.id,
      hostelId: data['hostelId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      targetGroup: TargetGroup.values.firstWhere(
        (e) => e.name == data['targetGroup'],
        orElse: () => TargetGroup.all,
      ),
      targetValue: data['targetValue'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'],
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'noticeId': noticeId,
      'hostelId': hostelId,
      'title': title,
      'content': content,
      'targetGroup': targetGroup.name,
      'targetValue': targetValue,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'createdByName': createdByName,
    };
  }

  // CopyWith
  NoticeModel copyWith({
    String? noticeId,
    String? hostelId,
    String? title,
    String? content,
    TargetGroup? targetGroup,
    String? targetValue,
    DateTime? createdAt,
    String? createdBy,
    String? createdByName,
  }) {
    return NoticeModel(
      noticeId: noticeId ?? this.noticeId,
      hostelId: hostelId ?? this.hostelId,
      title: title ?? this.title,
      content: content ?? this.content,
      targetGroup: targetGroup ?? this.targetGroup,
      targetValue: targetValue ?? this.targetValue,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
    );
  }
}
