import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/complaint_status.dart';

class ComplaintModel {
  final String complaintId;
  final String residentId;
  final String userId;
  final String hostelId;
  final String category;
  final String description;
  final List<String> imageUrls;
  final ComplaintStatus status;
  final String? priority;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  
  // New fields for resolution timeframe & notifications
  final String? studentName;
  final String? estimatedResolutionTime;   // e.g. "2 days", "Within 24 hours"
  final DateTime? estimatedResolutionDate;
  final bool studentNotified;

  ComplaintModel({
    required this.complaintId,
    required this.residentId,
    required this.userId,
    required this.hostelId,
    required this.category,
    required this.description,
    required this.imageUrls,
    required this.status,
    this.priority,
    this.adminNotes,
    required this.createdAt,
    this.resolvedAt,
    this.studentName,
    this.estimatedResolutionTime,
    this.estimatedResolutionDate,
    this.studentNotified = false,
  });

  // From Firestore
  factory ComplaintModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ComplaintModel(
      complaintId: doc.id,
      residentId: data['residentId'] ?? '',
      userId: data['userId'] ?? '',
      hostelId: data['hostelId'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ComplaintStatus.open,
      ),
      priority: data['priority'],
      adminNotes: data['adminNotes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
      studentName: data['studentName'],
      estimatedResolutionTime: data['estimatedResolutionTime'],
      estimatedResolutionDate: data['estimatedResolutionDate'] != null
          ? (data['estimatedResolutionDate'] as Timestamp).toDate()
          : null,
      studentNotified: data['studentNotified'] ?? false,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'complaintId': complaintId,
      'residentId': residentId,
      'userId': userId,
      'hostelId': hostelId,
      'category': category,
      'description': description,
      'imageUrls': imageUrls,
      'status': status.name,
      'priority': priority,
      'adminNotes': adminNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'studentName': studentName,
      'estimatedResolutionTime': estimatedResolutionTime,
      'estimatedResolutionDate': estimatedResolutionDate != null 
          ? Timestamp.fromDate(estimatedResolutionDate!) : null,
      'studentNotified': studentNotified,
    };
  }

  // CopyWith
  ComplaintModel copyWith({
    String? complaintId,
    String? residentId,
    String? userId,
    String? hostelId,
    String? category,
    String? description,
    List<String>? imageUrls,
    ComplaintStatus? status,
    String? priority,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? studentName,
    String? estimatedResolutionTime,
    DateTime? estimatedResolutionDate,
    bool? studentNotified,
  }) {
    return ComplaintModel(
      complaintId: complaintId ?? this.complaintId,
      residentId: residentId ?? this.residentId,
      userId: userId ?? this.userId,
      hostelId: hostelId ?? this.hostelId,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      studentName: studentName ?? this.studentName,
      estimatedResolutionTime: estimatedResolutionTime ?? this.estimatedResolutionTime,
      estimatedResolutionDate: estimatedResolutionDate ?? this.estimatedResolutionDate,
      studentNotified: studentNotified ?? this.studentNotified,
    );
  }
}
