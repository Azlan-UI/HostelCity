import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/student_nav_provider.dart';
import '../../providers/badge_providers.dart';
import '../student/student_home_screen.dart';
import '../student/student_active_stay_dashboard.dart';
import '../student/my_bookings_screen.dart';
import '../student/student_dues_screen.dart';
import '../student/student_edit_profile_screen.dart';
import '../../widgets/common/bottom_nav/student_bottom_nav.dart';

/// Shell scaffold for the Student role.
class StudentShellScreen extends ConsumerStatefulWidget {
  const StudentShellScreen({super.key});

  @override
  ConsumerState<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends ConsumerState<StudentShellScreen> {
  late PageController _pageController;

  static const _pages = <Widget>[
    _KeepAlivePage(child: StudentHomeScreen()),
    _KeepAlivePage(child: StudentActiveStayDashboard()),
    _KeepAlivePage(child: MyBookingsScreen()),
    _KeepAlivePage(child: StudentDuesScreen()),
    _KeepAlivePage(child: StudentEditProfileScreen()),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(studentNavIndexProvider);
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNavChange(int newIndex) {
    final currentIndex = ref.read(studentNavIndexProvider);
    if (newIndex != currentIndex) {
      ref.read(studentNavIndexProvider.notifier).state = newIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(studentNavIndexProvider);
    final pendingCount = ref.watch(pendingBookingsBadgeProvider);
    final dueCount = ref.watch(dueDuesBadgeProvider);

    ref.listen<int>(studentNavIndexProvider, (previous, next) {
      void syncPage() {
        if (!mounted) return;
        if (!_pageController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) => syncPage());
          return;
        }
        final rounded = _pageController.page?.round();
        if (rounded == next) return;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) => syncPage());
    });

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to preserve tab structure
        children: _pages,
      ),
      bottomNavigationBar: StudentBottomNav(
        currentIndex: currentIndex,
        onTabChanged: _handleNavChange,
        bookingBadgeCount: pendingCount,
        duesBadgeCount: dueCount,
      ),
    );
  }
}

// Wrapper to preserve state of pages when switching tabs in PageView
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
