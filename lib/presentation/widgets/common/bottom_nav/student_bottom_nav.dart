import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nav_tab.dart';
import '../../../providers/auth_providers.dart';

class StudentBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final int bookingBadgeCount;
  final int duesBadgeCount;

  const StudentBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.bookingBadgeCount,
    required this.duesBadgeCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(
                color: AppColors.accent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NavTab(
                    icon: Icons.search_rounded,
                    label: 'Explore',
                    index: 0,
                    isActive: currentIndex == 0,
                    onTap: () => onTabChanged(0),
                  ),
                  NavTab(
                    icon: Icons.hotel_rounded,
                    label: 'My Stay',
                    index: 1,
                    isActive: currentIndex == 1,
                    onTap: () => onTabChanged(1),
                  ),
                  NavTab(
                    icon: Icons.history_rounded,
                    label: 'Bookings',
                    index: 2,
                    isActive: currentIndex == 2,
                    onTap: () => onTabChanged(2),
                    badgeCount: bookingBadgeCount,
                  ),
                  NavTab(
                    icon: Icons.payments_outlined,
                    label: 'Dues',
                    index: 3,
                    isActive: currentIndex == 3,
                    onTap: () => onTabChanged(3),
                    badgeCount: duesBadgeCount,
                  ),
                  NavTab(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    index: 4,
                    isActive: currentIndex == 4,
                    onTap: () => onTabChanged(4),
                    imageUrl: user?.profileImageUrl,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
