import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/verification_enums.dart';

class VerificationDocument {
  final String documentId;
  final DocumentType type;
  final String url;
  final DateTime uploadedAt;
  final String? notes;

  VerificationDocument({
    required this.documentId,
    required this.type,
    required this.url,
    required this.uploadedAt,
    this.notes,
  });

  factory VerificationDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VerificationDocument(
      documentId: doc.id,
      type: DocumentType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => DocumentType.certificate,
      ),
      url: data['url'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      notes: data['notes'],
    );
  }

  factory VerificationDocument.fromMap(Map<String, dynamic> data) {
    return VerificationDocument(
      documentId: data['documentId'] ?? '',
      type: DocumentType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => DocumentType.certificate,
      ),
      url: data['url'] ?? '',
      uploadedAt: data['uploadedAt'] is Timestamp
          ? (data['uploadedAt'] as Timestamp).toDate()
          : DateTime.now(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'documentId': documentId,
      'type': type.name,
      'url': url,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'notes': notes,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'type': type.name,
      'url': url,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'notes': notes,
    };
  }

  VerificationDocument copyWith({
    String? documentId,
    DocumentType? type,
    String? url,
    DateTime? uploadedAt,
    String? notes,
  }) {
    return VerificationDocument(
      documentId: documentId ?? this.documentId,
      type: type ?? this.type,
      url: url ?? this.url,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      notes: notes ?? this.notes,
    );
  }
}
