import 'package:cloud_firestore/cloud_firestore.dart';

enum DuesStatus { pending, paid, overdue }

class DuesModel {
  final String duesId;
  final String studentId;
  final String hostelId;
  final String bookingId;
  final String month; // YYYY-MM format
  final double rentAmount;
  final double fineAmount;
  final double totalAmount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final DuesStatus status;
  final DateTime createdAt;
  final String? studentName;
  final String? hostelName;

  DuesModel({
    required this.duesId,
    required this.studentId,
    required this.hostelId,
    required this.bookingId,
    required this.month,
    required this.rentAmount,
    this.fineAmount = 0,
    required this.totalAmount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.createdAt,
    this.studentName,
    this.hostelName,
  });

  bool get isOverdue => status != DuesStatus.paid && DateTime.now().isAfter(dueDate);

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  double calculatedFine(double dailyFineAmount) {
    if (!isOverdue) return 0;
    return daysOverdue * dailyFineAmount;
  }

  factory DuesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DuesModel(
      duesId: doc.id,
      studentId: data['studentId'] ?? '',
      hostelId: data['hostelId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      month: data['month'] ?? '',
      rentAmount: (data['rentAmount'] ?? 0).toDouble(),
      fineAmount: (data['fineAmount'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      paidDate: data['paidDate'] != null
          ? (data['paidDate'] as Timestamp).toDate()
          : null,
      status: DuesStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => DuesStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      studentName: data['studentName'],
      hostelName: data['hostelName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'hostelId': hostelId,
      'bookingId': bookingId,
      'month': month,
      'rentAmount': rentAmount,
      'fineAmount': fineAmount,
      'totalAmount': totalAmount,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'studentName': studentName,
      'hostelName': hostelName,
    };
  }

  DuesModel copyWith({
    String? duesId,
    String? studentId,
    String? hostelId,
    String? bookingId,
    String? month,
    double? rentAmount,
    double? fineAmount,
    double? totalAmount,
    DateTime? dueDate,
    DateTime? paidDate,
    DuesStatus? status,
    DateTime? createdAt,
    String? studentName,
    String? hostelName,
  }) {
    return DuesModel(
      duesId: duesId ?? this.duesId,
      studentId: studentId ?? this.studentId,
      hostelId: hostelId ?? this.hostelId,
      bookingId: bookingId ?? this.bookingId,
      month: month ?? this.month,
      rentAmount: rentAmount ?? this.rentAmount,
      fineAmount: fineAmount ?? this.fineAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      studentName: studentName ?? this.studentName,
      hostelName: hostelName ?? this.hostelName,
    );
  }
}
