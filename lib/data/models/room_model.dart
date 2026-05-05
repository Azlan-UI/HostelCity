import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String roomId;
  final String hostelId;
  final String roomNumber;
  final int floor;
  final int capacity;
  final String roomType;
  final double rent;
  final int? occupiedBeds;

  RoomModel({
    required this.roomId,
    required this.hostelId,
    required this.roomNumber,
    required this.floor,
    required this.capacity,
    required this.roomType,
    required this.rent,
    this.occupiedBeds,
  });

  // Check if room is full
  bool get isFull => (occupiedBeds ?? 0) >= capacity;

  // Available beds
  int get availableBeds => capacity - (occupiedBeds ?? 0);

  // From Firestore
  factory RoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoomModel(
      roomId: doc.id,
      hostelId: data['hostelId'] ?? '',
      roomNumber: data['roomNumber'] ?? '',
      floor: data['floor'] ?? 0,
      capacity: data['capacity'] ?? 0,
      roomType: data['roomType'] ?? '',
      rent: (data['rent'] ?? 0).toDouble(),
      occupiedBeds: data['occupiedBeds'],
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'hostelId': hostelId,
      'roomNumber': roomNumber,
      'floor': floor,
      'capacity': capacity,
      'roomType': roomType,
      'rent': rent,
      'occupiedBeds': occupiedBeds,
    };
  }

  // CopyWith
  RoomModel copyWith({
    String? roomId,
    String? hostelId,
    String? roomNumber,
    int? floor,
    int? capacity,
    String? roomType,
    double? rent,
    int? occupiedBeds,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      hostelId: hostelId ?? this.hostelId,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      roomType: roomType ?? this.roomType,
      rent: rent ?? this.rent,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
    );
  }
}
