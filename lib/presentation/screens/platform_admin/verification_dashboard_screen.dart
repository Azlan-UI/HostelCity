import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../providers/verification_providers.dart';
import '../../../domain/enums/verification_enums.dart';
import 'user_verification_detail_screen.dart';


class VerificationDashboardScreen extends ConsumerWidget {
  const VerificationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'User Verifications',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(Icons.auto_fix_high, color: AppColors.primary),
              tooltip: 'Grandfather Old Accounts',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('System Migration', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    content: Text(
                      'This will automatically approve all legacy users that are currently pending. Use this only for system migration.',
                      style: GoogleFonts.inter(),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Confirm Migration', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing migration...')),
                    );
                    
                    final count = await ref.read(verificationRepositoryProvider).migrateExistingAccounts();
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Successfully approved $count legacy users.')),
                      );
                      ref.invalidate(pendingVerificationsProvider);
                      ref.invalidate(approvedVerificationsProvider);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                }
              },
            ),
          ],
          bottom: TabBar(
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _VerificationList(status: VerificationStatus.pending),
            _VerificationList(status: VerificationStatus.approved),
            _VerificationList(status: VerificationStatus.rejected),
          ],
        ),
      ),
    );
  }
}

class _VerificationList extends ConsumerWidget {
  final VerificationStatus status;

  const _VerificationList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = status == VerificationStatus.pending
        ? pendingVerificationsProvider
        : status == VerificationStatus.approved
            ? approvedVerificationsProvider
            : rejectedVerificationsProvider;

    final usersAsync = ref.watch(provider);

    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == VerificationStatus.pending
                      ? Icons.hourglass_empty_rounded
                      : status == VerificationStatus.approved
                          ? Icons.verified_user_rounded
                          : Icons.gpp_bad_rounded,
                  size: 64,
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${status.name} verifications',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserVerificationCard(user: user);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _UserVerificationCard extends StatelessWidget {
  final UserModel user;

  const _UserVerificationCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.name[0].toUpperCase(),
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          user.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoleBadge(user.role.displayName),
                const SizedBox(width: 8),
                Icon(Icons.location_on, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 2),
                Text(
                  user.city,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.userVerificationDetail,
            arguments: user,
          );
        },
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
