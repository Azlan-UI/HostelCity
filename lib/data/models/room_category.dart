class RoomCategory {
  final int seaterType;
  final double rent;
  final int totalBeds;
  final int availableBeds;

  RoomCategory({
    required this.seaterType,
    required this.rent,
    required this.totalBeds,
    required this.availableBeds,
  });

  Map<String, dynamic> toMap() {
    return {
      'seaterType': seaterType,
      'rent': rent,
      'totalBeds': totalBeds,
      'availableBeds': availableBeds,
    };
  }

  factory RoomCategory.fromMap(Map<String, dynamic> map) {
    return RoomCategory(
      seaterType: map['seaterType'] ?? 0,
      rent: (map['rent'] ?? 0).toDouble(),
      totalBeds: map['totalBeds'] ?? 0,
      availableBeds: map['availableBeds'] ?? 0,
    );
  }
}

// NOTE: VerificationStatus enum removed from here.
// Use the canonical enum from domain/enums/verification_enums.dart instead.
