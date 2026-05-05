enum VerificationStatus {
  pending,
  approved,
  needsReview,
  rejected;

  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending Verification';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.needsReview:
        return 'Needs Review';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  /// Robust deserialization — handles legacy 'verified' → 'approved'
  static VerificationStatus fromString(String? value) {
    if (value == null) return VerificationStatus.pending;
    final lower = value.toLowerCase();
    if (lower == 'verified' || lower == 'approved') return VerificationStatus.approved;
    if (lower == 'needsreview' || lower == 'needs_review') return VerificationStatus.needsReview;
    return VerificationStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == lower,
      orElse: () => VerificationStatus.pending,
    );
  }
}

enum DocumentType {
  studentCard,
  certificate,
  cnic,
  hostelRegistration;

  String get displayName {
    switch (this) {
      case DocumentType.studentCard:
        return 'Student Card';
      case DocumentType.certificate:
        return 'Certificate';
      case DocumentType.cnic:
        return 'CNIC';
      case DocumentType.hostelRegistration:
        return 'Hostel Registration';
    }
  }
}
