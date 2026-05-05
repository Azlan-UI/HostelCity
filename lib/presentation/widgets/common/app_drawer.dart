import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/enums/verification_enums.dart';
import '../../providers/auth_providers.dart';
import '../../providers/student_nav_provider.dart';
import '../../providers/admin_nav_provider.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../services/prefs_service.dart';
import '../../../../core/router/app_router.dart';

class AppDrawer extends ConsumerWidget {
  final Widget? currentScreen;
  const AppDrawer({super.key, this.currentScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Drawer(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _DrawerHeader(ref: ref),
          Expanded(
            child: userAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('Error loading profile')),
              data: (user) {
                if (user == null) return const SizedBox.shrink();
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (user.role == UserRole.student)
                      ..._studentItems(context, ref),
                    if (user.role == UserRole.hostelAdmin)
                      ..._adminItems(context, ref),
                    if (user.role == UserRole.platformAdmin)
                      ..._platformItems(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                          color: AppColors.border, height: 28),
                    ),
                    _DrawerTile(
                      icon: Icons.school_rounded,
                      title: 'Restart Onboarding',
                      onTap: () => _restartOnboarding(context),
                    ),
                    _DrawerTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      onTap: () => _logout(context, ref),
                      isDestructive: true,
                    ),
                  ],
                );
              },
            ),
          ),
          _DrawerFooter(),
        ],
      ),
    );
  }

  // ── Student nav items — use shell provider for tab items ─────────────────
  List<Widget> _studentItems(BuildContext context, WidgetRef ref) => [
        _DrawerTile(
          icon: Icons.search_rounded,
          title: 'Find Hostels',
          onTap: () => _goToStudentShellTab(context, ref, 0),
        ),
        _DrawerTile(
          icon: Icons.hotel_rounded,
          title: 'My Active Stay',
          onTap: () => _goToStudentShellTab(context, ref, 1),
        ),
        _DrawerTile(
          icon: Icons.history_rounded,
          title: 'Booking History',
          onTap: () => _goToStudentShellTab(context, ref, 2),
        ),
        _DrawerTile(
          icon: Icons.support_agent_rounded,
          title: 'My Complaints',
          onTap: () => _openStudentComplaints(context),
        ),
        _DrawerTile(
          icon: Icons.payments_rounded,
          title: 'My Dues',
          onTap: () => _goToStudentShellTab(context, ref, 3),
        ),
        _DrawerTile(
          icon: Icons.person_outline_rounded,
          title: 'Edit Profile',
          onTap: () => _goToStudentShellTab(context, ref, 4),
        ),
      ];

  /// Pops the drawer, selects a shell tab, and pops any route pushed above the
  /// student shell (e.g. [StudentComplaintScreen]) so navigation is not stuck.
  void _goToStudentShellTab(BuildContext context, WidgetRef ref, int index) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ref.read(studentNavIndexProvider.notifier).state = index;
      final nav = Navigator.of(context);
      if (nav.canPop()) {
        nav.pop();
      }
    });
  }

  /// Opens complaints when coming from the shell; if already on complaints, only closes the drawer.
  void _openStudentComplaints(BuildContext context) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final nav = Navigator.of(context);
      if (!nav.canPop()) {
        nav.pushNamed(AppRouter.studentComplaints);
      }
    });
  }

  List<Widget> _adminItems(BuildContext context, WidgetRef ref) => [
        _DrawerTile(
          icon: Icons.dashboard_rounded,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ref.read(adminNavIndexProvider.notifier).state = 0;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.adminDashboard,
                (_) => false,
              );
            });
          },
        ),
        _DrawerTile(
          icon: Icons.payments_rounded,
          title: 'Dues Management',
          onTap: () {
            Navigator.pop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ref.read(adminNavIndexProvider.notifier).state = 1;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.adminDashboard,
                (_) => false,
              );
            });
          },
        ),
        _DrawerTile(
          icon: Icons.edit_rounded,
          title: 'Edit Profile',
          onTap: () {
            Navigator.pop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ref.read(adminNavIndexProvider.notifier).state = 4;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.adminDashboard,
                (_) => false,
              );
            });
          },
        ),
      ];

  List<Widget> _platformItems(BuildContext context) => [
        _DrawerTile(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Platform Overview',
          onTap: () => _navRoot(context, AppRouter.platformDashboard),
        ),
        _DrawerTile(
          icon: Icons.verified_user_rounded,
          title: 'User Verifications',
          onTap: () => _nav(context, AppRouter.verificationDashboard),
        ),
      ];

  void _nav(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  void _navRoot(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  Future<void> _restartOnboarding(BuildContext context) async {
    Navigator.pop(context);
    await PrefsService().resetOnboarding();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onboarding will show on next login')),
      );
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }
      await ref.read(prefsServiceProvider).clear();
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.login, (_) => false);
      }
    }
  }
}

// ─── Frosted glass header ─────────────────────────────────────────────────────
class _DrawerHeader extends ConsumerWidget {
  final WidgetRef ref;
  const _DrawerHeader({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    Color vColor = AppColors.warning;
    IconData vIcon = Icons.pending_rounded;
    String vLabel = 'Pending';

    if (user != null) {
      switch (user.verificationStatus) {
        case VerificationStatus.approved:
          vColor = AppColors.success;
          vIcon = Icons.verified_rounded;
          vLabel = 'Verified';
          break;
        case VerificationStatus.rejected:
          vColor = AppColors.error;
          vIcon = Icons.cancel_rounded;
          vLabel = 'Rejected';
          break;
        case VerificationStatus.needsReview:
          vColor = AppColors.warning;
          vIcon = Icons.rate_review_rounded;
          vLabel = 'In Review';
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 28),
      decoration: BoxDecoration(
        // Subtle vertical gradient instead of garish indigo
        gradient: LinearGradient(
          colors: [const Color(0xFF111118), const Color(0xFF1C1C2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25), width: 2),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  child: Text(
                    user?.name[0].toUpperCase() ?? 'U',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Loading…',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user?.role.displayName ?? '',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user != null) ...[
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: vColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: vColor.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(vIcon, color: vColor, size: 13),
                  const SizedBox(width: 6),
                  Text(
                    vLabel,
                    style: GoogleFonts.plusJakartaSans(
                        color: vColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Drawer tile ──────────────────────────────────────────────────────────────
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.error : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          hoverColor: color.withValues(alpha: 0.05),
          splashColor: color.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _DrawerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Hostel Finder v1.2.0 · PropTech Edition',
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textTertiary,
          fontSize: 11,
        ),
      ),
    );
  }
}
