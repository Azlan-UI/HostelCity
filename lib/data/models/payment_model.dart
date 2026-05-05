import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/payment_status.dart';

enum PaymentMethod { upi, card, easypaisa, jazzcash, wallet, applePay, googlePay }

class PaymentModel {
  final String paymentId;
  final String? bookingId; // Linked to booking for students
  final String? residentId; // Linked to resident for existing management
  final String hostelId;
  final String userId;
  final String? month;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final DateTime dueDate;
  final DateTime? paidDate;
  final DateTime createdAt;
  final String? notes;

  PaymentModel({
    required this.paymentId,
    this.bookingId,
    this.residentId,
    required this.hostelId,
    required this.userId,
    this.month,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    this.transactionId,
    required this.dueDate,
    this.paidDate,
    required this.createdAt,
    this.notes,
  });

  bool get isOverdue {
    return status == PaymentStatus.pending && DateTime.now().isAfter(dueDate);
  }

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      paymentId: doc.id,
      bookingId: data['bookingId'],
      residentId: data['residentId'],
      hostelId: data['hostelId'] ?? '',
      userId: data['userId'] ?? '',
      month: data['month'],
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'PKR',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PaymentStatus.pending,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == (data['method'] ?? 'card'),
        orElse: () => PaymentMethod.card,
      ),
      transactionId: data['transactionId'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      paidDate: data['paidDate'] != null 
          ? (data['paidDate'] as Timestamp).toDate() 
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'residentId': residentId,
      'hostelId': hostelId,
      'userId': userId,
      'month': month,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'method': method.name,
      'transactionId': transactionId,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }
}
