class FirebaseConstants {
  FirebaseConstants._();

  // Collection Names
  static const String usersCollection = 'users';
  static const String hostelsCollection = 'hostels';
  static const String roomsCollection = 'rooms';
  static const String bedsCollection = 'beds';
  static const String residentsCollection = 'residents';
  static const String paymentsCollection = 'payments';
  static const String complaintsCollection = 'complaints';
  static const String noticesCollection = 'notices';
  static const String reviewsCollection = 'reviews';
  
  // Storage Paths
  static const String usersStorage = 'users';
  static const String hostelsStorage = 'hostels';
  static const String complaintsStorage = 'complaints';
  
  // FCM Topics
  static String hostelTopic(String hostelId) => 'hostel_$hostelId';
  static String floorTopic(String hostelId, int floor) => 'hostel_${hostelId}_floor_$floor';
  static String roomTopic(String hostelId, String roomId) => 'hostel_${hostelId}_room_$roomId';
  
  // Field Names
  static const String userId = 'userId';
  static const String hostelId = 'hostelId';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String approved = 'approved';
  static const String isActive = 'isActive';
}
