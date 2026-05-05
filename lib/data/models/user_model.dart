import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/enums/verification_enums.dart';
import '../../domain/enums/gender_type.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? hostelId;
  final String? profileImageUrl;
  final String province;
  final String city;
  final DateTime createdAt;
  final GenderType? gender;
  
  // Verification fields
  final VerificationStatus verificationStatus;
  final String? verificationRejectionReason;
  final double? verificationConfidenceScore;
  final String? verificationOcrText;
  
  // Student verification fields
  final String? studentCardUrl;
  final List<String> certificatesUrls;
  
  // Hostel admin verification fields
  final String? cnicUrl;
  final bool biometricVerified;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.hostelId,
    this.profileImageUrl,
    required this.province,
    required this.city,
    required this.createdAt,
    this.gender,
    this.verificationStatus = VerificationStatus.pending,
    this.verificationRejectionReason,
    this.verificationConfidenceScore,
    this.verificationOcrText,
    this.studentCardUrl,
    this.certificatesUrls = const [],
    this.cnicUrl,
    this.biometricVerified = false,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.student,
      ),
      hostelId: data['hostelId'],
      profileImageUrl: data['profileImageUrl'],
      province: data['province'] ?? 'PB',
      city: data['city'] ?? 'Lahore',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verificationStatus: VerificationStatus.fromString(data['verificationStatus'] as String?),
      verificationRejectionReason: data['verificationRejectionReason'],
      verificationConfidenceScore: (data['verificationConfidenceScore'] as num?)?.toDouble(),
      verificationOcrText: data['verificationOcrText'],
      studentCardUrl: data['studentCardUrl'],
      certificatesUrls: List<String>.from(data['certificatesUrls'] ?? []),
      cnicUrl: data['cnicUrl'],
      biometricVerified: data['biometricVerified'] ?? false,
      gender: data['gender'] != null 
          ? GenderType.values.firstWhere((e) => e.name == data['gender'], orElse: () => GenderType.boys) 
          : null,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'hostelId': hostelId,
      'profileImageUrl': profileImageUrl,
      'province': province,
      'city': city,
      'createdAt': Timestamp.fromDate(createdAt),
      'verificationStatus': verificationStatus.name,
      'verificationRejectionReason': verificationRejectionReason,
      'verificationConfidenceScore': verificationConfidenceScore,
      'verificationOcrText': verificationOcrText,
      'studentCardUrl': studentCardUrl,
      'certificatesUrls': certificatesUrls,
      'cnicUrl': cnicUrl,
      'biometricVerified': biometricVerified,
      'gender': gender?.name,
    };
  }

  // CopyWith
  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? hostelId,
    String? profileImageUrl,
    String? province,
    String? city,
    DateTime? createdAt,
    VerificationStatus? verificationStatus,
    String? verificationRejectionReason,
    double? verificationConfidenceScore,
    String? verificationOcrText,
    String? studentCardUrl,
    List<String>? certificatesUrls,
    String? cnicUrl,
    bool? biometricVerified,
    GenderType? gender,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      hostelId: hostelId ?? this.hostelId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      province: province ?? this.province,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationRejectionReason: verificationRejectionReason ?? this.verificationRejectionReason,
      verificationConfidenceScore: verificationConfidenceScore ?? this.verificationConfidenceScore,
      verificationOcrText: verificationOcrText ?? this.verificationOcrText,
      studentCardUrl: studentCardUrl ?? this.studentCardUrl,
      certificatesUrls: certificatesUrls ?? this.certificatesUrls,
      cnicUrl: cnicUrl ?? this.cnicUrl,
      biometricVerified: biometricVerified ?? this.biometricVerified,
      gender: gender ?? this.gender,
    );
  }
}
