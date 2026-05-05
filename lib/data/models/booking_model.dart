import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, paid, canceled, expired }

class BookingModel {
  final String bookingId;
  final String studentId;
  final String hostelId;
  final int seaterType;
  final double rent;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? hostelName; // Cache for display
  final String? hostelCity; // Cache for display
  final bool termsAccepted;

  BookingModel({
    required this.bookingId,
    required this.studentId,
    required this.hostelId,
    required this.seaterType,
    required this.rent,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.hostelName,
    this.hostelCity,
    this.termsAccepted = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'hostelId': hostelId,
      'seaterType': seaterType,
      'rent': rent,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'hostelName': hostelName,
      'hostelCity': hostelCity,
      'termsAccepted': termsAccepted,
    };
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: doc.id,
      studentId: data['studentId'] ?? '',
      hostelId: data['hostelId'] ?? '',
      seaterType: data['seaterType'] ?? 0,
      rent: (data['rent'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      hostelName: data['hostelName'],
      hostelCity: data['hostelCity'],
      termsAccepted: data['termsAccepted'] ?? false,
    );
  }
}
