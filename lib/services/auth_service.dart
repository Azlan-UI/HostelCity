import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/user_model.dart';
import '../domain/enums/user_role.dart';
import '../domain/enums/verification_enums.dart';
import '../core/constants/firebase_constants.dart';
import './storage_service.dart';
import './document_verification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String province,
    required String city,
    String? phone,
    XFile? studentCardFile,
    List<XFile>? certificateFiles,
    XFile? cnicFile,
  }) async {
    User? user;
    String currentStep = 'initializing';
    List<String> uploadedUrls = []; // Track uploads for cleanup
    
    try {
      // STEP 1: Validate documents via local OCR before proceeding
      // Note: Duplicate email check is handled by Firebase Auth natively
      // (throws 'email-already-in-use'). We removed the pre-auth Firestore
      // query that caused permission errors for unauthenticated users.
      currentStep = 'validating documents';
      final docService = DocumentVerificationService();
      double? finalConfidenceScore;
      // New accounts start pending; auto-approved after 30s (see ensureRegistrationAutoApproval).
      VerificationStatus initialStatus = VerificationStatus.pending;
      String? finalDocumentHash;
      String? extractedOcrText;
      
      try {
        if (role == UserRole.student && studentCardFile != null) {
          var result = await docService.verifyStudentCard(studentCardFile);
          
          // If strict verification fails, try generic fallback
          if (!result.isValid) {
            // Only block if it's a duplicate document
            if (result.extractedText.contains('REJECTED')) {
              throw Exception(result.extractedText);
            }
            // Otherwise fall back to generic verification
            result = await docService.verifyGenericDocument(studentCardFile);
            if (!result.isValid) {
              throw Exception('Document could not be verified. Please upload a clearer image.');
            }
          }
          finalConfidenceScore = result.confidenceScore;
          finalDocumentHash = result.documentHash;
          extractedOcrText = result.extractedText;
        } else if (role == UserRole.hostelAdmin && cnicFile != null) {
          var result = await docService.verifyCNIC(cnicFile);
          
          // If strict verification fails, try generic fallback
          if (!result.isValid) {
            if (result.extractedText.contains('REJECTED')) {
              throw Exception(result.extractedText);
            }
            result = await docService.verifyGenericDocument(cnicFile);
            if (!result.isValid) {
              throw Exception('Document could not be verified. Please upload a clearer image.');
            }
          }
          finalConfidenceScore = result.confidenceScore;
          finalDocumentHash = result.documentHash;
          extractedOcrText = result.extractedText;
        }
        
      } finally {
        docService.dispose();
      }

      // STEP 2: Create Firebase Auth account
      currentStep = 'creating account';
      try {
        final UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: email,
              password: password,
            )
            .timeout(const Duration(seconds: 25));
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw Exception(
            'An incomplete account exists with this email. '
            'Please contact support to resolve this issue, or try a different email address.'
          );
        }
        rethrow;
      }

      if (user == null) {
        throw Exception('Account creation failed. Please try again.');
      }

      // STEP 3: Upload documents with individual timeouts
      try {
        currentStep = 'uploading documents';
        String? studentCardUrl;
        List<String> certificatesUrls = [];
        String? cnicUrl;

        // Upload student card (90 second timeout for large files/slow connections)
        if (studentCardFile != null) {
          currentStep = 'uploading student card';
          studentCardUrl = await _storageService
              .uploadStudentCard(user.uid, studentCardFile)
              .timeout(
                const Duration(seconds: 90),
                onTimeout: () => throw Exception('Student card upload timed out. File may be too large or connection is slow.'),
              );
          uploadedUrls.add(studentCardUrl);
          print('✓ Student card uploaded');
        }

        // Upload certificates (90 seconds each)
        if (certificateFiles != null && certificateFiles.isNotEmpty) {
          for (int i = 0; i < certificateFiles.length; i++) {
            currentStep = 'uploading certificate ${i + 1}/${certificateFiles.length}';
            final certUrl = await _storageService
                .uploadCertificate(user.uid, certificateFiles[i])
                .timeout(
                  const Duration(seconds: 90),
                  onTimeout: () => throw Exception('Certificate ${i + 1} upload timed out. File may be too large or connection is slow.'),
                );
            certificatesUrls.add(certUrl);
            uploadedUrls.add(certUrl);
            print('✓ Certificate ${i + 1}/${certificateFiles.length} uploaded');
          }
        }

        // Upload CNIC (90 second timeout)
        if (cnicFile != null) {
          currentStep = 'uploading CNIC';
          cnicUrl = await _storageService
              .uploadCNIC(user.uid, cnicFile)
              .timeout(
                const Duration(seconds: 90),
                onTimeout: () => throw Exception('CNIC upload timed out. File may be too large or connection is slow.'),
              );
          uploadedUrls.add(cnicUrl);
          print('✓ CNIC uploaded');
        }

        // STEP 4: Create user document in Firestore
        currentStep = 'saving user data';
        final userModel = UserModel(
          userId: user.uid,
          name: name,
          email: email.toLowerCase(), // Store lowercase for consistency
          phone: phone,
          role: role,
          province: province,
          city: city,
          createdAt: DateTime.now(),
          verificationStatus: initialStatus,
          verificationConfidenceScore: finalConfidenceScore,
          verificationOcrText: extractedOcrText,
          studentCardUrl: studentCardUrl,
          certificatesUrls: certificatesUrls,
          cnicUrl: cnicUrl,
        );

        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toFirestore())
            .timeout(const Duration(seconds: 25));

        // STEP 5: Update display name
        currentStep = 'finalizing';
        await user.updateDisplayName(name).timeout(const Duration(seconds: 10));

        // STEP 6: Save document hash to prevent duplicate registrations
        if (finalDocumentHash != null && finalDocumentHash.isNotEmpty) {
          currentStep = 'saving document hash';
          final hashDocService = DocumentVerificationService();
          await hashDocService.saveDocumentHash(finalDocumentHash, user.uid);
          hashDocService.dispose();
        }

        print('✅ Registration successful for: $email');
        return userModel;
        
      } catch (e) {
        // ROLLBACK: Delete Firebase Auth account if document upload/creation failed
        currentStep = 'rolling back due to failure';
        print('⚠️ Registration failed. Rolling back changes...');
        
        try {
          // Delete uploaded files from storage
          if (uploadedUrls.isNotEmpty) {
            print('🗑️ Cleaning up ${uploadedUrls.length} uploaded file(s)...');
            await _storageService.deleteImages(uploadedUrls);
          }
          
          // Delete the Firebase Auth account
          print('🗑️ Deleting Firebase Auth account for: ${user.email}');
          await user.delete();
          
          // Sign out to clear any cached auth state
          await _auth.signOut();
          print('✅ Rollback complete - account and uploads removed');
        } catch (rollbackError) {
          print('❌ Rollback error: $rollbackError');
          // Try to at least sign out
          try {
            await _auth.signOut();
          } catch (_) {}
        }
        
        rethrow;
      }
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e, 'registration');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception(
          'The request timed out during $currentStep. '
          'Please check your internet connection and try again.'
        );
      }
      if (e.toString().contains('Sign up failed') || 
          e.toString().contains('Failed to upload') ||
          e.toString().contains('An account with this email')) {
        rethrow;
      }
      throw Exception('Registration failed: $e');
    }
  }

  // Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Sign in failed');

      // Get user document from Firestore
      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      var userModel = UserModel.fromFirestore(userDoc);
      userModel = await ensureRegistrationAutoApproval(userModel);
      return userModel;
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e, 'user lookup');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// After 30s from registration, pending/needsReview users are approved automatically.
  /// Platform admins can still approve sooner via the verification dashboard.
  Future<UserModel> ensureRegistrationAutoApproval(UserModel user) async {
    if (user.verificationStatus == VerificationStatus.approved ||
        user.verificationStatus == VerificationStatus.rejected) {
      return user;
    }
    if (user.verificationStatus != VerificationStatus.pending &&
        user.verificationStatus != VerificationStatus.needsReview) {
      return user;
    }
    final secondsSinceReg = DateTime.now().difference(user.createdAt).inSeconds;
    if (secondsSinceReg < 30) return user;

    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.userId)
          .update({'verificationStatus': VerificationStatus.approved.name});

      final snap = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.userId)
          .get();
      if (!snap.exists) return user;
      return UserModel.fromFirestore(snap);
    } catch (_) {
      return user;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e, 'profile data retrieval');
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .update(updates);

        if (name != null) {
          await user.updateDisplayName(name);
        }
      }
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e, 'profile update');
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // Assign hostel to user (for residents)
  Future<void> assignHostelToUser(String userId, String hostelId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({'hostelId': hostelId});
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e, 'hostel assignment');
    } catch (e) {
      throw Exception('Failed to assign hostel: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  // Handle Firestore exceptions
  Exception _handleFirestoreException(FirebaseException e, String operation) {
    if (e.code == 'permission-denied') {
      return Exception('Access Denied: You do not have permission during $operation. ${e.message}');
    } else if (e.code == 'not-found') {
      return Exception('Not Found: The requested data for $operation does not exist.');
    }
    return Exception('Database Error during $operation: ${e.message}');
  }
}
