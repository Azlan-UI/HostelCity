class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Hostel Finder';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int hostelsPerPage = 20;
  static const int paymentsPerPage = 30;
  static const int complaintsPerPage = 20;
  static const int noticesPerPage = 20;
  
  // Image Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImagesPerHostel = 10;
  static const int maxImagesPerComplaint = 5;
  static const int imageQuality = 80;
  
  // Map
  static const double defaultZoom = 3.0;
  static const double markerZoom = 15.0;
  static const double defaultLatitude = 20.0; 
  static const double defaultLongitude = 0.0;
  
  // Search Filters
  static const double minRent = 0;
  static const double maxRent = 50000;
  static const double defaultMaxDistance = 10.0; // km
  
  // Payment
  static const int paymentDueDay = 5; // 5th of each month
  static const int overdueGraceDays = 3;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 500;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  
  // Cache
  static const Duration cacheExpiry = Duration(hours: 24);
}
