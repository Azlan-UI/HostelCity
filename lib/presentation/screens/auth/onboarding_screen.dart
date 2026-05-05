/// Onboarding Screen — shown once to new users after their first login.
/// Swipeable PageView with smooth animations, pulsing highlights, and
/// skip/next/finish controls. Consistent with Electric Indigo / Vibrant Teal theme.
///
/// To restart onboarding, call: PrefsService().resetOnboarding()
library;

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/prefs_service.dart';


/// Data model for each onboarding page
class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;
  final List<_Feature> features;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.features,
  });
}

class _Feature {
  final IconData icon;
  final String label;
  const _Feature({required this.icon, required this.label});
}

class OnboardingScreen extends StatefulWidget {
  /// Route to navigate to after onboarding is complete
  final String destinationRoute;

  const OnboardingScreen({
    super.key,
    required this.destinationRoute,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Pulsing glow animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Content for each onboarding page
  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Welcome to Hostel Finder',
      description: 'Find the perfect hostel near your university. Browse, compare, and book — all in one place.',
      icon: Icons.home_work_rounded,
      iconBgColor: AppColors.primary,
      features: [
        _Feature(icon: Icons.search, label: 'Smart hostel search'),
        _Feature(icon: Icons.map, label: 'Map-based discovery'),
        _Feature(icon: Icons.verified, label: 'Verified listings'),
      ],
    ),
    _OnboardingPage(
      title: 'Explore & Book',
      description: 'View detailed hostel profiles with photos, rooms, facilities, and reviews. Book your bed instantly.',
      icon: Icons.hotel_rounded,
      iconBgColor: AppColors.accent,
      features: [
        _Feature(icon: Icons.photo_library, label: 'Photo galleries'),
        _Feature(icon: Icons.bed, label: 'Room categories & pricing'),
        _Feature(icon: Icons.star, label: 'Student reviews'),
      ],
    ),
    _OnboardingPage(
      title: 'Manage Your Stay',
      description: 'Track your dues, pay rent, and raise complaints directly from the app. Your admin responds in real-time.',
      icon: Icons.dashboard_rounded,
      iconBgColor: AppColors.info,
      features: [
        _Feature(icon: Icons.payments, label: 'Pay rent & track dues'),
        _Feature(icon: Icons.support_agent, label: 'Raise complaints with photos'),
        _Feature(icon: Icons.timer, label: 'Resolution timeframe tracking'),
      ],
    ),
    _OnboardingPage(
      title: 'Stay Informed',
      description: 'Get hostel notices, view your booking history, and navigate with an interactive map showing your hostel location.',
      icon: Icons.notifications_active_rounded,
      iconBgColor: AppColors.warning,
      features: [
        _Feature(icon: Icons.announcement, label: 'Hostel notices & alerts'),
        _Feature(icon: Icons.history, label: 'Booking history'),
        _Feature(icon: Icons.location_on, label: 'Live hostel location map'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    await PrefsService().setOnboardingComplete(true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(widget.destinationRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1340), // Deep indigo
              Color(0xFF2D1B69), // Rich purple
              Color(0xFF0D2137), // Deep teal-blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 16),
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], size);
                  },
                ),
              ),

              // Dots + Next/Finish
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page dots
                    Row(
                      children: List.generate(_pages.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          width: isActive ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.textPrimary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      }),
                    ),

                    // Next / Finish button
                    GestureDetector(
                      onTap: _nextPage,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                          horizontal: _currentPage == _pages.length - 1 ? 32 : 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (_currentPage < _pages.length - 1) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_forward, color: AppColors.textPrimary, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing icon with glow
          ScaleTransition(
            scale: _pulseAnimation,
            child: FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: page.iconBgColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: page.iconBgColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: page.iconBgColor.withValues(alpha: 0.25),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  page.icon,
                  size: 64,
                  color: page.iconBgColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Title
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              page.title,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          FadeInUp(
            delay: const Duration(milliseconds: 350),
            child: Text(
              page.description,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary.withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 36),

          // Features list with highlight
          ...List.generate(page.features.length, (index) {
            return FadeInLeft(
              delay: Duration(milliseconds: 450 + (index * 100)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: page.iconBgColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        page.features[index].icon,
                        color: page.iconBgColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        page.features[index].label,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary.withValues(alpha: 0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
