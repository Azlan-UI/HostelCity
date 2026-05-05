import 'package:cloud_firestore/cloud_firestore.dart';

class BedModel {
  final String bedId;
  final String roomId;
  final String bedNumber;
  final bool occupied;
  final String? residentId;

  BedModel({
    required this.bedId,
    required this.roomId,
    required this.bedNumber,
    required this.occupied,
    this.residentId,
  });

  // From Firestore
  factory BedModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BedModel(
      bedId: doc.id,
      roomId: data['roomId'] ?? '',
      bedNumber: data['bedNumber'] ?? '',
      occupied: data['occupied'] ?? false,
      residentId: data['residentId'],
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'bedId': bedId,
      'roomId': roomId,
      'bedNumber': bedNumber,
      'occupied': occupied,
      'residentId': residentId,
    };
  }

  // CopyWith
  BedModel copyWith({
    String? bedId,
    String? roomId,
    String? bedNumber,
    bool? occupied,
    String? residentId,
  }) {
    return BedModel(
      bedId: bedId ?? this.bedId,
      roomId: roomId ?? this.roomId,
      bedNumber: bedNumber ?? this.bedNumber,
      occupied: occupied ?? this.occupied,
      residentId: residentId ?? this.residentId,
    );
  }
}
