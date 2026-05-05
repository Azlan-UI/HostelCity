import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_providers.dart';
import '../../../domain/enums/user_role.dart';
import '../../../domain/enums/verification_enums.dart';
import '../../../services/prefs_service.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuth();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    // Add a minimum delay for the splash animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Use authStateProvider.future to wait for the first auth event properly
    try {
      final user = await ref.read(authStateProvider.future);
      
      if (!mounted) return;

      if (user == null) {
        // User is not logged in
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      } else {
        // User is logged in, fetch full user data to check role
        final currentUser = await ref.read(currentUserProvider.future);

        if (!mounted) return;

        if (currentUser == null) {
          // Document doesn't exist, sign out and go to login
          await ref.read(authServiceProvider).signOut();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
          }
          return;
        }

        final authService = ref.read(authServiceProvider);
        final routedUser =
            await authService.ensureRegistrationAutoApproval(currentUser);

        if (!mounted) return;

        // Check verification status
        if (routedUser.verificationStatus != VerificationStatus.approved) {
          if (routedUser.verificationStatus == VerificationStatus.rejected) {
            Navigator.of(context).pushReplacementNamed(
              AppRouter.verificationRejected,
              arguments: routedUser.verificationRejectionReason ?? 'No reason provided',
            );
          } else {
            Navigator.of(context).pushReplacementNamed(AppRouter.verificationPending);
          }
          return;
        }

        // Determine destination based on role
        String destination;
        switch (routedUser.role) {
          case UserRole.student:
            destination = AppRouter.studentHome;
            break;
          case UserRole.hostelAdmin:
            destination = AppRouter.adminDashboard;
            break;
          case UserRole.platformAdmin:
            destination = AppRouter.platformDashboard;
            break;
        }

        // Check if onboarding has been completed
        final prefs = PrefsService();
        final onboardingDone = await prefs.isOnboardingComplete();

        if (!mounted) return;

        if (!onboardingDone) {
          // Show onboarding first, passing the destination route
          Navigator.of(context).pushReplacementNamed(
            AppRouter.onboarding,
            arguments: destination,
          );
        } else {
          Navigator.of(context).pushReplacementNamed(destination);
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data in splash: $e');
      // On error, sign out if possible and go to login
      try {
        await ref.read(authServiceProvider).signOut();
      } catch (_) {}
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              ScaleTransition(
                scale: _pulseAnimation,
                child: FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      size: 72,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Hostel Finder',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  'Your Perfect Stay Awaits',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 64),
              
              // Loading Indicator
              FadeIn(
                delay: const Duration(milliseconds: 800),
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}