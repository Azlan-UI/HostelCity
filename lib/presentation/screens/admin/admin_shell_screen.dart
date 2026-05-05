import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_nav_provider.dart';
import '../../widgets/common/bottom_nav/admin_bottom_nav.dart';
import 'admin_complaints_screen.dart';
import 'admin_dues_dashboard_screen.dart';
import 'admin_residents_screen.dart';
import 'hostel_admin_dashboard_screen.dart';
import 'hostel_admin_edit_profile_screen.dart';

/// Hostel admin root: glass bottom navigation (same pattern as student shell).
class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  late PageController _pageController;

  static const _pages = <Widget>[
    _KeepAlivePage(child: HostelAdminDashboardScreen()),
    _KeepAlivePage(child: AdminDuesDashboardScreen()),
    _KeepAlivePage(child: AdminComplaintsScreen()),
    _KeepAlivePage(child: AdminResidentsScreen()),
    _KeepAlivePage(child: HostelAdminEditProfileScreen()),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(adminNavIndexProvider);
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNavChange(int newIndex) {
    final currentIndex = ref.read(adminNavIndexProvider);
    if (newIndex != currentIndex) {
      ref.read(adminNavIndexProvider.notifier).state = newIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(adminNavIndexProvider);

    ref.listen<int>(adminNavIndexProvider, (previous, next) {
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App?'),
            content: const Text(
              'Are you sure you want to close the application?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: AdminBottomNav(
          currentIndex: currentIndex,
          onTabChanged: _handleNavChange,
        ),
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
