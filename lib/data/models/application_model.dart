import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { pending, approved, rejected, cancelled }

class ApplicationModel {
  final String applicationId;
  final String studentId;
  final String hostelId;
  final int seaterType;
  final ApplicationStatus status;
  final DateTime createdAt;
  final String? adminNotes;
  
  // Helper fields for UI
  final String? studentName;
  final String? hostelName;

  ApplicationModel({
    required this.applicationId,
    required this.studentId,
    required this.hostelId,
    required this.seaterType,
    required this.status,
    required this.createdAt,
    this.adminNotes,
    this.studentName,
    this.hostelName,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      applicationId: doc.id,
      studentId: data['studentId'] ?? '',
      hostelId: data['hostelId'] ?? '',
      seaterType: data['seaterType'] ?? 0,
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => ApplicationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      adminNotes: data['adminNotes'],
      studentName: data['studentName'],
      hostelName: data['hostelName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'hostelId': hostelId,
      'seaterType': seaterType,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'adminNotes': adminNotes,
      'studentName': studentName,
      'hostelName': hostelName,
    };
  }

  ApplicationModel copyWith({
    String? applicationId,
    String? studentId,
    String? hostelId,
    int? seaterType,
    ApplicationStatus? status,
    DateTime? createdAt,
    String? adminNotes,
    String? studentName,
    String? hostelName,
  }) {
    return ApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      studentId: studentId ?? this.studentId,
      hostelId: hostelId ?? this.hostelId,
      seaterType: seaterType ?? this.seaterType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      adminNotes: adminNotes ?? this.adminNotes,
      studentName: studentName ?? this.studentName,
      hostelName: hostelName ?? this.hostelName,
    );
  }
}
