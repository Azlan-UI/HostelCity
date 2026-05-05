enum UserRole {
  platformAdmin,
  hostelAdmin,
  student;

  String get displayName {
    switch (this) {
      case UserRole.platformAdmin:
        return 'Platform Admin';
      case UserRole.hostelAdmin:
        return 'Hostel Admin';
      case UserRole.student:
        return 'Student';
    }
  }
}
