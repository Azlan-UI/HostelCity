import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class VerificationResult {
  final bool isValid;
  final double confidenceScore;
  final String extractedText;
  final List<String> matchedKeywords;
  final String documentHash;
  
  VerificationResult({
    required this.isValid,
    required this.confidenceScore,
    required this.extractedText,
    required this.matchedKeywords,
    required this.documentHash,
  });
}

class DocumentVerificationService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Student Card keywords — expanded to be far more lenient
  // Includes generic academic terms + Pakistani university abbreviations
  final List<String> _studentKeywords = [
    // Generic academic
    'university', 'college', 'institute', 'school', 'student', 'card',
    'campus', 'semester', 'id', 'identification', 'enrollment', 'enrolment',
    'roll', 'registration', 'reg', 'admission', 'department', 'dept',
    'faculty', 'program', 'degree', 'bachelor', 'master', 'phd',
    'scholar', 'academic', 'session', 'batch', 'class', 'section',
    'education', 'valid', 'expiry', 'issued', 'library',
    // Pakistani university abbreviations
    'uet', 'nust', 'lums', 'comsats', 'fast', 'iqra', 'bahria',
    'szabist', 'numl', 'aiou', 'iiu', 'uol', 'ucp', 'umt',
    'gift', 'ned', 'aku', 'pu', 'bzu', 'gcu', 'qau', 'lgu',
    'ust', 'uos', 'iub', 'gcuf', 'gcwuf', 'riphah',
    // Common Urdu/English hybrid
    'naam', 'name', 'father', 'walid', 'shakl', 'photo',
  ];
  
  // CNIC keywords (Pakistan) — expanded
  final List<String> _cnicKeywords = [
    'pakistan', 'national', 'identity', 'card', 'islamic', 'republic',
    'name', 'father', 'husband', 'gender', 'country', 'stay', 
    'date', 'issue', 'birth', 'expiry', 'nadra', 'cnic',
    'identification', 'number', 'address', 'district', 'province',
    'male', 'female', 'holder', 'citizen',
  ];

  /// Verify a student card — lenient mode: needs only 1 keyword match.
  Future<VerificationResult> verifyStudentCard(XFile file) async {
    return _verifyDocument(file, _studentKeywords, minKeywords: 1);
  }

  /// Verify a CNIC — needs 2 keyword matches (was 3, reduced for leniency).
  Future<VerificationResult> verifyCNIC(XFile file) async {
    return _verifyDocument(file, _cnicKeywords, minKeywords: 2);
  }

  /// Generic document verification — accepts ANY document that has readable text.
  /// Used as fallback when strict verification fails.
  /// Returns isValid=true as long as text was extracted, with a lower confidence.
  Future<VerificationResult> verifyGenericDocument(XFile file) async {
    try {
      final docHash = await calculateDocumentHash(file);
      
      final isDuplicate = await isDocumentDuplicate(docHash);
      if (isDuplicate) {
        return VerificationResult(
          isValid: false,
          confidenceScore: 0.0,
          extractedText: 'REJECTED: Duplicate document detected across users.',
          matchedKeywords: [],
          documentHash: docHash,
        );
      }

      final inputImage = InputImage.fromFilePath(file.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final text = recognizedText.text.toLowerCase();
      
      // Accept if ANY text was found — it's a real document
      final hasText = text.trim().length > 5;
      
      return VerificationResult(
        isValid: hasText,
        confidenceScore: hasText ? 0.5 : 0.0,
        extractedText: text,
        matchedKeywords: hasText ? ['generic_document'] : [],
        documentHash: docHash,
      );
    } catch (e) {
      // If OCR fails entirely (e.g. platform issue), still allow with lowest confidence
      // The document will go to manual review (pending status)
      final docHash = await calculateDocumentHash(file);
      return VerificationResult(
        isValid: true,
        confidenceScore: 0.3,
        extractedText: 'OCR unavailable — manual review required',
        matchedKeywords: ['ocr_fallback'],
        documentHash: docHash,
      );
    }
  }

  Future<String> calculateDocumentHash(XFile file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> isDocumentDuplicate(String hash) async {
    try {
      final querySnapshot = await _firestore
          .collection('documentHashes')
          .where('hash', isEqualTo: hash)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking duplicate document hash: $e');
      return false; // Fail open if Firestore is temporarily down
    }
  }

  Future<void> saveDocumentHash(String hash, String userId) async {
    try {
      await _firestore.collection('documentHashes').add({
        'hash': hash,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving document hash: $e');
    }
  }

  Future<VerificationResult> _verifyDocument(
    XFile file, 
    List<String> validKeywords, 
    {int minKeywords = 1}
  ) async {
    try {
      // 1. Calculate hash first
      final docHash = await calculateDocumentHash(file);
      
      // 2. Check for duplicates immediately
      final isDuplicate = await isDocumentDuplicate(docHash);
      if (isDuplicate) {
        return VerificationResult(
          isValid: false,
          confidenceScore: 0.0,
          extractedText: 'REJECTED: Duplicate document detected across users.',
          matchedKeywords: [],
          documentHash: docHash,
        );
      }

      // 3. Process image for text if not duplicate
      final inputImage = InputImage.fromFilePath(file.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final text = recognizedText.text.toLowerCase();
      
      if (text.isEmpty) {
        // No text at all — might be a heavily graphical card
        // Still allow it but with low confidence for manual review
        return VerificationResult(
          isValid: true,
          confidenceScore: 0.4,
          extractedText: 'No text detected — manual review required',
          matchedKeywords: ['no_text_fallback'],
          documentHash: docHash,
        );
      }
      
      final matched = <String>[];
      for (final keyword in validKeywords) {
        if (text.contains(keyword)) {
          matched.add(keyword);
        }
      }
      
      // Also count if there are number sequences that look like ID numbers
      final idPattern = RegExp(r'\d{5,}');
      final hasIdNumber = idPattern.hasMatch(text);
      if (hasIdNumber) {
        matched.add('id_number_detected');
      }
      
      // Calculate confidence based on matches vs requirements
      // Cap at 0.95 purely from OCR
      final rawScore = matched.length / (minKeywords * 1.5);
      final confidence = min(0.95, rawScore);
      final isValid = matched.length >= minKeywords;

      return VerificationResult(
        isValid: isValid,
        confidenceScore: isValid ? max(0.6, confidence) : confidence,
        extractedText: text,
        matchedKeywords: matched,
        documentHash: docHash,
      );
    } catch (e) {
      print('Error verifying document: $e');
      // On error, don't block registration — allow with manual review
      final docHash = await calculateDocumentHash(file).catchError((_) => '');
      return VerificationResult(
        isValid: true,
        confidenceScore: 0.3,
        extractedText: 'Verification error — manual review required',
        matchedKeywords: ['error_fallback'],
        documentHash: docHash,
      );
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}

final documentVerificationServiceProvider = Provider<DocumentVerificationService>((ref) {
  final service = DocumentVerificationService();
  ref.onDispose(() => service.dispose());
  return service;
});
