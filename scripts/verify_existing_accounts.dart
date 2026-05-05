import 'package:cloud_firestore/cloud_firestore.dart';

/// One-time migration script to verify existing accounts
/// 
/// This script updates all existing user accounts to have 'approved' verification status
/// so they can continue accessing the app. This is necessary because the new registration
/// flow requires all accounts to have a verification status.
/// 
/// HOW TO RUN:
/// 1. Save this file
/// 2. Run: dart scripts/verify_existing_accounts.dart
/// 3. Or integrate into your Firebase Cloud Functions for automated execution

Future<void> migrateExistingAccounts(FirebaseFirestore firestore) async {
  print('🔄 Starting migration: Verifying existing accounts...\n');
  
  try {
    // Query all users
    print('📊 Fetching all user accounts...');
    final usersSnapshot = await firestore.collection('users').get();
    
    if (usersSnapshot.docs.isEmpty) {
      print('✅ No users found. Migration complete.');
      return;
    }
    
    print('Found ${usersSnapshot.docs.length} user account(s)\n');
    
    int updatedCount = 0;
    int alreadyVerifiedCount = 0;
    int errorCount = 0;
    
    // Process each user
    for (final doc in usersSnapshot.docs) {
      try {
        final data = doc.data();
        final userId = doc.id;
        final email = data['email'] ?? 'unknown';
        final role = data['role'] ?? 'unknown';
        final currentStatus = data['verificationStatus'];
        
        // Check if user already has a verification status
        if (currentStatus != null && currentStatus != 'pending') {
          print('⏭️  Skipping ${email} (already ${currentStatus})');
          alreadyVerifiedCount++;
          continue;
        }
        
        // Update to approved status
        await firestore.collection('users').doc(userId).update({
          'verificationStatus': 'approved',
          'migratedAt': FieldValue.serverTimestamp(),
        });
        
        print('✅ Approved: $email (Role: $role)');
        updatedCount++;
        
      } catch (e) {
        print('❌ Error updating ${doc.id}: $e');
        errorCount++;
      }
    }
    
    // Print summary
    print('\n========== MIGRATION SUMMARY ==========');
    print('Total accounts found: ${usersSnapshot.docs.length}');
    print('✅ Updated to approved: $updatedCount');
    print('⏭️  Already verified: $alreadyVerifiedCount');
    print('❌ Errors: $errorCount');
    print('======================================\n');
    
  } catch (e) {
    print('❌ Migration failed: $e');
    rethrow;
  }
}

/// Alternative: Firebase Cloud Function version
/// Deploy this to run automatically
///
/// ```javascript
/// const functions = require('firebase-functions');
/// const admin = require('firebase-admin');
/// admin.initializeApp();
///
/// exports.verifyExistingAccounts = functions.https.onRequest(async (req, res) => {
///   const db = admin.firestore();
///   const usersRef = db.collection('users');
///   
///   const snapshot = await usersRef.get();
///   let updated = 0;
///   
///   const batch = db.batch();
///   snapshot.forEach(doc => {
///     const data = doc.data();
///     if (!data.verificationStatus || data.verificationStatus === 'pending') {
///       batch.update(doc.ref, {
///         verificationStatus: 'approved',
///         migratedAt: admin.firestore.FieldValue.serverTimestamp()
///       });
///       updated++;
///     }
///   });
///   
///   await batch.commit();
///   res.json({ success: true, updated });
/// });
/// ```

void main() async {
  print('⚠️  MANUAL MIGRATION REQUIRED\n');
  print('This is a template script. To migrate existing accounts:');
  print('');
  print('OPTION 1: Use Firebase Console');
  print('  1. Go to Firestore Database in Firebase Console');
  print('  2. Navigate to the "users" collection');
  print('  3. For each user document:');
  print('     - Click on the document');
  print('     - Add/Update field: verificationStatus = "approved"');
  print('     - Save');
  print('');
  print('OPTION 2: Use Firebase Admin SDK (Recommended)');
  print('  1. Set up Firebase Admin SDK in a Node.js project');
  print('  2. Use the Cloud Function code provided above');
  print('  3. Deploy and call the function');
  print('');
  print('OPTION 3: Manual Firebase CLI');
  print('  Run this command for each user:');
  print('  firebase firestore:update users/{userId} --data verificationStatus=approved');
  print('');
  print('NOTE: This only needs to be run ONCE to grandfather existing accounts.');
  print('New accounts will automatically have verification status set during registration.');
}
