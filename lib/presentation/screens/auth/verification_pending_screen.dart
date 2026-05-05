import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/enums/verification_enums.dart';
import '../../providers/auth_providers.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/common/custom_button.dart';

class VerificationPendingScreen extends ConsumerStatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  ConsumerState<VerificationPendingScreen> createState() =>
      _VerificationPendingScreenState();
}

class _VerificationPendingScreenState
    extends ConsumerState<VerificationPendingScreen> {
  Timer? _tick;
  int _secondsLeft = 30;
  bool _autoApprovalRunning = false;
  String? _scheduledForUserId;
  bool _redirectedApproved = false;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  int _computeSecondsLeft(DateTime createdAt) {
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return (30 - elapsed).clamp(0, 30);
  }

  Future<void> _tryAutoApprove() async {
    if (_autoApprovalRunning) return;
    final user = await ref.read(currentUserProvider.future);
    if (user == null || !mounted) return;
    if (user.verificationStatus == VerificationStatus.approved) return;
    if (_computeSecondsLeft(user.createdAt) > 0) return;

    _autoApprovalRunning = true;
    try {
      final auth = ref.read(authServiceProvider);
      await auth.ensureRegistrationAutoApproval(user);
      ref.invalidate(currentUserProvider);
    } finally {
      _autoApprovalRunning = false;
    }
    if (mounted) setState(() {});
  }

  void _ensureTicker(UserModel user) {
    if (_scheduledForUserId == user.userId) return;
    _scheduledForUserId = user.userId;
    _tick?.cancel();
    setState(() => _secondsLeft = _computeSecondsLeft(user.createdAt));
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final left = _computeSecondsLeft(user.createdAt);
      setState(() => _secondsLeft = left);
      if (left <= 0) {
        _tick?.cancel();
        _tryAutoApprove();
      }
    });
    if (_secondsLeft <= 0) {
      _tryAutoApprove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            if (user == null) {
              return const Center(child: Text('No user session'));
            }

            if (user.verificationStatus == VerificationStatus.approved) {
              if (!_redirectedApproved) {
                _redirectedApproved = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.splash,
                    (route) => false,
                  );
                });
              }
              return const Center(child: CircularProgressIndicator());
            }

            _ensureTicker(user);

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.hourglass_top_rounded,
                          size: 80,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'Awaiting approval',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'Your account is in the review queue. A platform admin may approve you sooner. Otherwise you will be approved automatically.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _secondsLeft > 0
                          ? 'Auto-approval in $_secondsLeft s — then tap Continue or log in again.'
                          : 'Auto-approval window passed. Tap Continue to refresh.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              context,
                              Icons.admin_panel_settings_outlined,
                              'Admin review',
                              'A platform admin can approve your account at any time from the verification dashboard.',
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(
                              context,
                              Icons.timer_outlined,
                              'Automatic approval',
                              'About 30 seconds after registration your account is approved automatically if still pending.',
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(
                              context,
                              Icons.login_rounded,
                              'Next step',
                              'After approval, use Continue to enter the app (or log in again from the login screen).',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: CustomButton(
                        text: 'Continue',
                        icon: Icons.refresh_rounded,
                        onPressed: () async {
                          final refreshed =
                              await ref.refresh(currentUserProvider.future);
                          if (!mounted || refreshed == null) return;
                          if (refreshed.verificationStatus ==
                              VerificationStatus.approved) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRouter.splash,
                              (route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _secondsLeft > 0
                                      ? 'Still waiting (~$_secondsLeft s until auto-approval).'
                                      : 'Still pending — try again shortly or wait for an admin.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: CustomButton(
                        text: 'Sign Out',
                        isOutlined: true,
                        onPressed: () async {
                          await authService.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRouter.login,
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
