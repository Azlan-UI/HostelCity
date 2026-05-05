import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_providers.dart';
import '../../../data/models/user_model.dart';

/// Centralised auth-gate used by every screen that fetches Firestore data.
/// Waits for the auth stream, redirects to login if unauthenticated, then
/// loads [currentUserProvider] (forces token-refresh) before building content.
class AuthGate extends ConsumerWidget {
  final Widget Function(UserModel user) builder;
  const AuthGate({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Auth error: $e')),
      data: (firebaseUser) {
        if (firebaseUser == null) {
          // Not logged in — redirect
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
          });
          return const Center(child: CircularProgressIndicator());
        }

        final userAsync = ref.watch(currentUserProvider);
        return userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => FirestoreErrorFallback(
            isPermissionDenied: e.isFirestorePermissionError,
            onRetry: () => ref.invalidate(currentUserProvider),
          ),
          data: (user) {
            if (user == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed(AppRouter.login);
              });
              return const Center(child: CircularProgressIndicator());
            }
            return builder(user);
          },
        );
      },
    );
  }
}

/// Extension to identify Firestore permission-denied errors.
extension FirestoreErrorX on Object {
  bool get isFirestorePermissionError =>
      toString().contains('permission-denied') ||
      toString().contains('PERMISSION_DENIED');
}

/// Standard error fallback widget shown when Firestore throws permission-denied.
class FirestoreErrorFallback extends StatelessWidget {
  final bool isPermissionDenied;
  final VoidCallback? onRetry;

  const FirestoreErrorFallback({
    super.key,
    required this.isPermissionDenied,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPermissionDenied ? Icons.lock_outline : Icons.wifi_off_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPermissionDenied ? 'Session Expired' : 'Something Went Wrong',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPermissionDenied
                  ? 'Your session has expired. Please sign in again.'
                  : 'Unable to load data. Please check your connection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (isPermissionDenied)
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRouter.login),
                icon: const Icon(Icons.login),
                label: const Text('Sign In Again'),
              )
            else if (onRetry != null)
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
