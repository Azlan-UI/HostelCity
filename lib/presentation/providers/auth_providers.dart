import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../data/models/user_model.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth State Provider — streams FirebaseAuth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User UID — derived from the stream so it always reflects live auth.
// This is the KEY dependency other providers should watch to trigger re-fetch.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.uid;
});

// Current User Data Provider
// Watches currentUserIdProvider (not the full stream) so it re-evaluates
// exactly when the UID changes — including on logout → login transitions.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  // Watch the UID — this causes this provider to rebuild whenever auth changes.
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;

  // Force-refresh the ID token so Firestore never uses a stale cached token
  // from a previous session. This is the fix for the post-logout permission error.
  try {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.getIdToken(true);
    }
  } catch (_) {
    // If token refresh fails, proceed anyway — Firestore will catch it.
  }

  final authService = ref.read(authServiceProvider);
  return await authService.getCurrentUserData();
});
