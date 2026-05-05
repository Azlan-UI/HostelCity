import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../data/models/hostel_model.dart';
import '../../../../data/models/booking_model.dart';
import '../../providers/hostel_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/service_providers.dart';
import '../../providers/selected_room_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/payment/payment_gateway_dialog.dart';
import '../../widgets/hostel_detail/hostel_image_gallery.dart';
import '../../widgets/hostel_detail/hostel_header.dart';
import '../../widgets/hostel_detail/available_rooms.dart';
import '../../widgets/hostel_detail/facilities_section.dart';
import '../../widgets/hostel_detail/rules_section.dart';
import '../../widgets/hostel_detail/sticky_cta_button.dart';

class HostelDetailScreen extends ConsumerStatefulWidget {
  final String hostelId;
  /// Platform admin preview: full detail without booking CTA.
  final bool hideBookingCta;

  const HostelDetailScreen({
    super.key,
    required this.hostelId,
    this.hideBookingCta = false,
  });

  @override
  ConsumerState<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends ConsumerState<HostelDetailScreen> {
  final _scrollController = ScrollController();
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    // Reset room selection when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedRoomProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostelAsync = ref.watch(hostelByIdProvider(widget.hostelId));
    final reviewsAsync = ref.watch(hostelReviewsProvider(widget.hostelId));
    final averageRatingAsync = ref.watch(hostelAverageRatingProvider(widget.hostelId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBody: true,
      body: hostelAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading hostel details...'),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Could not load hostel', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        ),
        data: (hostel) {
          if (hostel == null) {
            return Center(
              child: Text('Hostel not found', style: Theme.of(context).textTheme.headlineSmall),
            );
          }
          return _buildContent(
            hostel,
            reviewsAsync,
            averageRatingAsync,
            widget.hideBookingCta,
          );
        },
      ),
    );
  }

  Widget _buildContent(
    HostelModel hostel,
    AsyncValue reviewsAsync,
    AsyncValue<double> averageRatingAsync,
    bool hideBookingCta,
  ) {
    final avgRating = averageRatingAsync.valueOrNull ?? 0.0;
    final reviewCount = reviewsAsync.whenOrNull(data: (r) => (r as List).length) ?? 0;

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Hero App Bar with Image Gallery ──────────────────────────
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: HostelImageGallery(
                  hostel: hostel,
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Name, badge, location, price, trust signals
                  FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: HostelHeader(
                      hostel: hostel,
                      averageRating: avgRating,
                      reviewCount: reviewCount,
                    ),
                  ),

                  SizedBox(height: 24.0),
                  _Divider(),
                  SizedBox(height: 24.0),

                  // Available Rooms
                  FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    delay: const Duration(milliseconds: 80),
                    child: AvailableRoomsSection(rooms: hostel.roomCategories),
                  ),

                  if (hostel.roomCategories.isNotEmpty) ...[
                    SizedBox(height: 24.0),
                    _Divider(),
                    SizedBox(height: 24.0),
                  ],

                  // Description
                  if (hostel.description != null && hostel.description!.isNotEmpty) ...[
                    FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      delay: const Duration(milliseconds: 120),
                      child: _DescriptionSection(description: hostel.description!),
                    ),
                    SizedBox(height: 24.0),
                    _Divider(),
                    SizedBox(height: 24.0),
                  ],

                  // Facilities
                  if (hostel.facilities.isNotEmpty) ...[
                    FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      delay: const Duration(milliseconds: 160),
                      child: FacilitiesSection(facilities: hostel.facilities),
                    ),
                    SizedBox(height: 24.0),
                    _Divider(),
                    SizedBox(height: 24.0),
                  ],

                  // Rules
                  if (hostel.rules.isNotEmpty) ...[
                    FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      delay: const Duration(milliseconds: 200),
                      child: RulesSection(rules: hostel.rules),
                    ),
                    SizedBox(height: 24.0),
                    _Divider(),
                    SizedBox(height: 24.0),
                  ],

                  // Nearby Universities
                  if (hostel.nearbyUniversities.isNotEmpty) ...[
                    FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      delay: const Duration(milliseconds: 240),
                      child: _NearbyUniversitiesSection(universities: hostel.nearbyUniversities),
                    ),
                    SizedBox(height: 24.0),
                    _Divider(),
                    SizedBox(height: 24.0),
                  ],

                  // Reviews
                  FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    delay: const Duration(milliseconds: 280),
                    child: _ReviewsSection(
                      reviewsAsync: reviewsAsync,
                      averageRating: avgRating,
                    ),
                  ),

                  // Bottom padding for sticky CTA
                  SizedBox(height: hideBookingCta ? 32.0 : 130.0),
                ],
              ),
            ),
          ],
        ),

        if (!hideBookingCta)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StickyBookingCTA(
              scrollOffset: 0,
              onBookPressed: () => _showBookingDialog(hostel),
            ),
          ),
      ],
    );
  }

  void _showBookingDialog(HostelModel hostel) {
    bool termsAccepted = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedRoom = ref.read(selectedRoomProvider);

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Booking',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedRoom != null
                          ? '${selectedRoom.seaterType}-Seater · Rs. ${selectedRoom.rent.toInt()}/month'
                          : 'No room selected',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fee info
                    if (hostel.securityFee > 0) ...[
                      _InfoRow(
                        icon: Icons.security_rounded,
                        color: AppColors.accent,
                        text: 'Security Fee: Rs. ${hostel.securityFee.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 10),
                    ],
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.warning,
                      text: 'Rent due by the ${hostel.rentDeadlineDays}th of each month',
                    ),
                    if (hostel.dailyFineAmount > 0) ...[
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.error,
                        text: 'Late payment fine: Rs. ${hostel.dailyFineAmount.toStringAsFixed(0)}/day',
                      ),
                    ],

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Terms checkbox
                    GestureDetector(
                      onTap: () => setDialogState(() => termsAccepted = !termsAccepted),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: termsAccepted,
                            onChanged: (val) => setDialogState(() => termsAccepted = val ?? false),
                            activeColor: AppColors.accent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: BorderSide(color: AppColors.textTertiary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'I accept the terms, fee structure, and hostel rules.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (selectedRoom == null || !termsAccepted)
                                ? null
                                : () => _handleBooking(hostel, selectedRoom.seaterType),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleBooking(HostelModel hostel, int seaterType) async {
    Navigator.pop(context);
    setState(() => _isBooking = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw Exception('Please log in to book.');

      final category = hostel.roomCategories.firstWhere((c) => c.seaterType == seaterType);

      final booking = BookingModel(
        bookingId: '',
        studentId: user.userId,
        hostelId: hostel.hostelId,
        seaterType: seaterType,
        rent: category.rent,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 48)),
        hostelName: hostel.name,
        hostelCity: hostel.city,
        termsAccepted: true,
      );

      final newBooking = await ref.read(bookingRepositoryProvider).createBooking(booking);

      if (mounted) {
        final success = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => PaymentGatewayDialog(booking: newBooking),
        );

        if (!mounted) return;

        if (success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🎉 Booking Confirmed! Bed Reserved.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Booking reserved. Pay within 48h to confirm.'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking Failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Divider(color: AppColors.border, height: 1),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatefulWidget {
  final String description;
  const _DescriptionSection({required this.description});

  @override
  State<_DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<_DescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this Hostel', style: Theme.of(context).textTheme.titleLarge!),
          SizedBox(height: 16.0),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstChild: Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
          SizedBox(height: 8.0),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less' : 'Read more',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyUniversitiesSection extends StatelessWidget {
  final List<String> universities;
  const _NearbyUniversitiesSection({required this.universities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('Nearby Universities', style: Theme.of(context).textTheme.titleLarge!),
        ),
        SizedBox(height: 16.0),
        ...universities.map((uni) => Container(
              margin: EdgeInsets.fromLTRB(24.0, 0, 24.0, 8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.school_rounded, color: AppColors.accent, size: 20),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Text(uni, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final AsyncValue reviewsAsync;
  final double averageRating;

  const _ReviewsSection({required this.reviewsAsync, required this.averageRating});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Text('Reviews', style: Theme.of(context).textTheme.titleLarge!),
              if (averageRating > 0) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.0),
        reviewsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('Failed to load reviews', style: TextStyle(color: AppColors.error)),
          ),
          data: (reviews) {
            final list = reviews as List;
            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.rate_review_rounded, size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text('No reviews yet', style: Theme.of(context).textTheme.bodySmall!),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: list.take(5).map((review) {
                return FadeInUp(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                              child: Text(
                                review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                                style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                review.userName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: AppColors.warning,
                                size: 15,
                              )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          review.comment,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
