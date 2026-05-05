import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/enums/gender_type.dart';
import '../../domain/enums/verification_enums.dart';
import 'room_category.dart';

class HostelModel {
  final String hostelId;
  final String name;
  final String address;
  final String city;
  final String area;
  final String province; // Province code
  final LatLng coordinates;
  final String registrationNumber;
  final String contactNumber;
  final String email;
  final GenderType genderType;
  final double minRent;
  final double maxRent;
  final List<String> facilities;
  final List<String> rules;
  final List<String> imageUrls;
  final List<String> nearbyUniversities;
  final bool approved;
  final String adminId;
  final DateTime createdAt;
  final String? description;
  final int? totalRooms;
  final int? totalBeds;
  final int? occupiedBeds;
  
  // Advanced Features Fields
  final List<RoomCategory> roomCategories;
  final VerificationStatus verificationStatus;
  final String? registrationDocumentUrl;

  // Image Sourcing & Caching
  final DateTime? imageCacheDate;
  final String? imageSourceAPI;

  // Dues Management Fields
  final double securityFee;
  final int rentDeadlineDays;
  final double dailyFineAmount;

  HostelModel({
    required this.hostelId,
    required this.name,
    required this.address,
    required this.city,
    required this.area,
    required this.province,
    required this.coordinates,
    required this.registrationNumber,
    required this.contactNumber,
    required this.email,
    required this.genderType,
    required this.minRent,
    required this.maxRent,
    required this.facilities,
    required this.rules,
    required this.imageUrls,
    required this.nearbyUniversities,
    required this.approved,
    required this.adminId,
    required this.createdAt,
    this.description,
    this.totalRooms,
    this.totalBeds,
    this.occupiedBeds,
    this.roomCategories = const [],
    this.verificationStatus = VerificationStatus.pending,
    this.registrationDocumentUrl,
    this.securityFee = 0,
    this.rentDeadlineDays = 7,
    this.dailyFineAmount = 0,
    this.imageCacheDate,
    this.imageSourceAPI,
  });

  double get occupancyRate {
    if (totalBeds == null || totalBeds == 0) return 0;
    return (occupiedBeds ?? 0) / totalBeds! * 100;
  }

  double distanceFrom(LatLng point) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, coordinates, point);
  }

  factory HostelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['coordinates'] as GeoPoint;
    
    return HostelModel(
      hostelId: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      area: data['area'] ?? '',
      province: data['province'] ?? 'PB',
      coordinates: LatLng(geoPoint.latitude, geoPoint.longitude),
      registrationNumber: data['registrationNumber'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      email: data['email'] ?? '',
      genderType: GenderType.values.firstWhere(
        (e) => e.name == data['genderType'],
        orElse: () => GenderType.mixed,
      ),
      minRent: (data['minRent'] ?? 0).toDouble(),
      maxRent: (data['maxRent'] ?? 0).toDouble(),
      facilities: List<String>.from(data['facilities'] ?? []),
      rules: List<String>.from(data['rules'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      nearbyUniversities: List<String>.from(data['nearbyUniversities'] ?? []),
      approved: data['approved'] ?? false,
      adminId: data['adminId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'],
      totalRooms: data['totalRooms'],
      totalBeds: data['totalBeds'],
      occupiedBeds: data['occupiedBeds'],
      roomCategories: (data['roomCategories'] as List? ?? [])
          .map((item) => RoomCategory.fromMap(item as Map<String, dynamic>))
          .toList(),
      verificationStatus: VerificationStatus.fromString(data['verificationStatus']),
      registrationDocumentUrl: data['registrationDocumentUrl'],
      securityFee: (data['securityFee'] ?? 0).toDouble(),
      rentDeadlineDays: data['rentDeadlineDays'] ?? 7,
      dailyFineAmount: (data['dailyFineAmount'] ?? 0).toDouble(),
      imageCacheDate: data['imageCacheDate'] != null ? (data['imageCacheDate'] as Timestamp).toDate() : null,
      imageSourceAPI: data['imageSourceAPI'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hostelId': hostelId,
      'name': name,
      'address': address,
      'city': city,
      'area': area,
      'province': province,
      'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
      'registrationNumber': registrationNumber,
      'contactNumber': contactNumber,
      'email': email,
      'genderType': genderType.name,
      'minRent': minRent,
      'maxRent': maxRent,
      'facilities': facilities,
      'rules': rules,
      'imageUrls': imageUrls,
      'nearbyUniversities': nearbyUniversities,
      'approved': approved,
      'adminId': adminId,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'totalRooms': totalRooms,
      'totalBeds': totalBeds,
      'occupiedBeds': occupiedBeds,
      'roomCategories': roomCategories.map((c) => c.toMap()).toList(),
      'verificationStatus': verificationStatus.name,
      'registrationDocumentUrl': registrationDocumentUrl,
      'securityFee': securityFee,
      'rentDeadlineDays': rentDeadlineDays,
      'dailyFineAmount': dailyFineAmount,
      'imageCacheDate': imageCacheDate != null ? Timestamp.fromDate(imageCacheDate!) : null,
      'imageSourceAPI': imageSourceAPI,
    };
  }

  HostelModel copyWith({
    String? hostelId,
    String? name,
    String? address,
    String? city,
    String? area,
    String? province,
    LatLng? coordinates,
    String? registrationNumber,
    String? contactNumber,
    String? email,
    GenderType? genderType,
    double? minRent,
    double? maxRent,
    List<String>? facilities,
    List<String>? rules,
    List<String>? imageUrls,
    List<String>? nearbyUniversities,
    bool? approved,
    String? adminId,
    DateTime? createdAt,
    String? description,
    int? totalRooms,
    int? totalBeds,
    int? occupiedBeds,
    List<RoomCategory>? roomCategories,
    VerificationStatus? verificationStatus,
    String? registrationDocumentUrl,
    double? securityFee,
    int? rentDeadlineDays,
    double? dailyFineAmount,
    DateTime? imageCacheDate,
    String? imageSourceAPI,
  }) {
    return HostelModel(
      hostelId: hostelId ?? this.hostelId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      area: area ?? this.area,
      province: province ?? this.province,
      coordinates: coordinates ?? this.coordinates,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      genderType: genderType ?? this.genderType,
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
      facilities: facilities ?? this.facilities,
      rules: rules ?? this.rules,
      imageUrls: imageUrls ?? this.imageUrls,
      nearbyUniversities: nearbyUniversities ?? this.nearbyUniversities,
      approved: approved ?? this.approved,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      totalRooms: totalRooms ?? this.totalRooms,
      totalBeds: totalBeds ?? this.totalBeds,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      roomCategories: roomCategories ?? this.roomCategories,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      registrationDocumentUrl: registrationDocumentUrl ?? this.registrationDocumentUrl,
      securityFee: securityFee ?? this.securityFee,
      rentDeadlineDays: rentDeadlineDays ?? this.rentDeadlineDays,
      dailyFineAmount: dailyFineAmount ?? this.dailyFineAmount,
      imageCacheDate: imageCacheDate ?? this.imageCacheDate,
      imageSourceAPI: imageSourceAPI ?? this.imageSourceAPI,
    );
  }
}
