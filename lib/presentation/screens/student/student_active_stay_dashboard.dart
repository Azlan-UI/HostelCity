import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../providers/student_providers.dart';
import '../../providers/hostel_providers.dart';
import '../../widgets/common/app_drawer.dart';
import '../../providers/hostel_image_fetch_provider.dart';

class StudentActiveStayDashboard extends ConsumerWidget {
  const StudentActiveStayDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentsAsync  = ref.watch(studentResidentsProvider);
    final currentResident = ref.watch(currentResidentDisplayProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => Scaffold.of(ctx).openDrawer(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
        actions: [
          if (residentsAsync.value != null && residentsAsync.value!.length > 1)
            _buildHostelSwitcher(context, ref, residentsAsync.value!),
        ],
      ),
      body: residentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (residents) {
          if (currentResident == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final hostelAsync =
              ref.watch(hostelByIdProvider(currentResident.hostelId));
          return hostelAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
            data: (hostel) {
              if (hostel == null) {
                return const Center(child: Text('Hostel not found'));
              }
              return _ActiveStayBody(
                resident: currentResident,
                hostel: hostel,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHostelSwitcher(
      BuildContext context, WidgetRef ref, List<dynamic> residents) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
      ),
      color: const Color(0xFF1A1A1A),
      tooltip: 'Switch Hostel',
      onSelected: (id) =>
          ref.read(selectedResidentIdProvider.notifier).state = id,
      itemBuilder: (_) => residents.map((r) {
        final hostelAsync = ref.watch(hostelByIdProvider(r.hostelId));
        final name = hostelAsync.whenOrNull(data: (h) => h?.name) ?? r.hostelId;
        return PopupMenuItem<String>(
          value: r.residentId,
          child: Text(name, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────
class _ActiveStayBody extends StatelessWidget {
  final dynamic resident;
  final dynamic hostel;
  const _ActiveStayBody({required this.resident, required this.hostel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110), // glass nav clearance
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Full-bleed hero ───────────────────────────────────────────
          FadeInDown(child: _HeroSection(hostel: hostel)),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Room card ─────────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 80),
                  child: _RoomCard(resident: resident),
                ),
                const SizedBox(height: 16),

                // ── Action tiles ──────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 140),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.payments_outlined,
                          label: 'My Dues',
                          sub: 'Pay & History',
                          color: AppColors.warning,
                          onTap: () => Navigator.pushNamed(
                              context, AppRouter.studentDues),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.support_agent_outlined,
                          label: 'Complaints',
                          sub: 'Raise Issue',
                          color: AppColors.info,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.studentComplaints,
                            arguments: {
                              'hostelId': hostel.hostelId,
                              'hostelName': hostel.name,
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Policies ──────────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _PoliciesCard(hostel: hostel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cinematic hero with glass info overlay ───────────────────────────────────
class _HeroSection extends ConsumerStatefulWidget {
  final dynamic hostel;
  const _HeroSection({required this.hostel});

  @override
  ConsumerState<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends ConsumerState<_HeroSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) triggerHostelImageFetch(ref, widget.hostel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = ref.watch(hostelImageUrlsProvider(widget.hostel.hostelId));
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;

    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: kIsWeb ? null : 800,
              placeholder: (_, __) => Container(color: AppColors.surfaceAlt),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceAlt,
                child: Icon(Icons.apartment_rounded,
                    size: 64, color: AppColors.textTertiary),
              ),
            )
          else
            Container(
              color: AppColors.surfaceAlt,
              child: Icon(Icons.apartment_rounded,
                  size: 64, color: AppColors.textTertiary),
            ),

          // Gradient overlay
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color(0xDD000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.35, 1.0],
              ),
            ),
          ),

          // Frosted glass info card at the bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YOU ARE STAYING AT',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.hostel.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 12, color: Colors.white54),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                              '${widget.hostel.area}, ${widget.hostel.city}',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      // View details button
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.hostelDetail,
                          arguments: widget.hostel.hostelId,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Room card ────────────────────────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  final dynamic resident;
  const _RoomCard({required this.resident});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Room Details', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentMint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.accentMint.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: AppColors.accentMint,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(resident.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                            color: AppColors.accentMint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                  child: _DetailItem(
                      icon: Icons.meeting_room_rounded,
                      label: 'Room',
                      value: resident.roomId)),
              Expanded(
                  child: _DetailItem(
                      icon: Icons.bed_rounded,
                      label: 'Bed',
                      value: resident.bedId)),
            ],
          ),
          Divider(height: 32, color: AppColors.border),
          Row(
            children: [
              Expanded(
                  child: _DetailItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Move-in',
                      value: _fmt(resident.moveInDate))),
              Expanded(
                  child: _DetailItem(
                      icon: Icons.fingerprint_rounded,
                      label: 'Booking',
                      value: resident.bookingId.toString().substring(0, 6).toUpperCase())),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

// ─── Action tile ──────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.sub,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(label,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(sub,
                style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ─── Policies card ────────────────────────────────────────────────────────────
class _PoliciesCard extends StatelessWidget {
  final dynamic hostel;
  const _PoliciesCard({required this.hostel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hostel Policies', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _PolicyRow(
            icon: Icons.timer_outlined,
            label: 'Rent Deadline',
            value: 'Day ${hostel.rentDeadlineDays} of month',
          ),
          Divider(height: 24, color: AppColors.border),
          _PolicyRow(
            icon: Icons.money_off_rounded,
            label: 'Late Fine',
            value: 'Rs. ${hostel.dailyFineAmount.toStringAsFixed(0)}/day',
          ),
          Divider(height: 24, color: AppColors.border),
          _PolicyRow(
            icon: Icons.security_rounded,
            label: 'Security Deposit',
            value: 'Rs. ${hostel.securityFee.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _PolicyRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}