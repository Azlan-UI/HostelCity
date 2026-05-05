import 'package:cloud_firestore/cloud_firestore.dart';

class ResidentModel {
  final String residentId;
  final String userId;
  final String hostelId;
  final String roomId;
  final String bedId;
  final String? bookingId; // Added for reference
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final bool isActive;
  final String? userName;
  final String? userEmail;
  final String? userPhone;

  ResidentModel({
    required this.residentId,
    required this.userId,
    required this.hostelId,
    required this.roomId,
    required this.bedId,
    this.bookingId,
    required this.moveInDate,
    this.moveOutDate,
    required this.isActive,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  // Calculate stay duration
  Duration get stayDuration {
    final endDate = moveOutDate ?? DateTime.now();
    return endDate.difference(moveInDate);
  }

  // From Firestore
  factory ResidentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResidentModel(
      residentId: doc.id,
      userId: data['userId'] ?? '',
      hostelId: data['hostelId'] ?? '',
      roomId: data['roomId'] ?? '',
      bedId: data['bedId'] ?? '',
      bookingId: data['bookingId'],
      moveInDate: (data['moveInDate'] as Timestamp).toDate(),
      moveOutDate: data['moveOutDate'] != null
          ? (data['moveOutDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      userName: data['userName'],
      userEmail: data['userEmail'],
      userPhone: data['userPhone'],
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'residentId': residentId,
      'userId': userId,
      'hostelId': hostelId,
      'roomId': roomId,
      'bedId': bedId,
      'bookingId': bookingId,
      'moveInDate': Timestamp.fromDate(moveInDate),
      'moveOutDate': moveOutDate != null ? Timestamp.fromDate(moveOutDate!) : null,
      'isActive': isActive,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
    };
  }

  // CopyWith
  ResidentModel copyWith({
    String? residentId,
    String? userId,
    String? hostelId,
    String? roomId,
    String? bedId,
    String? bookingId,
    DateTime? moveInDate,
    DateTime? moveOutDate,
    bool? isActive,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) {
    return ResidentModel(
      residentId: residentId ?? this.residentId,
      userId: userId ?? this.userId,
      hostelId: hostelId ?? this.hostelId,
      roomId: roomId ?? this.roomId,
      bedId: bedId ?? this.bedId,
      bookingId: bookingId ?? this.bookingId,
      moveInDate: moveInDate ?? this.moveInDate,
      moveOutDate: moveOutDate ?? this.moveOutDate,
      isActive: isActive ?? this.isActive,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
    );
  }
}
