import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/selected_room_provider.dart';
import '../common/glassmorphic_surface.dart';

class StickyBookingCTA extends ConsumerWidget {
  final double scrollOffset;
  final VoidCallback onBookPressed;

  const StickyBookingCTA({
    super.key,
    required this.scrollOffset,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRoom = ref.watch(selectedRoomProvider);
    final canBook = selectedRoom != null && selectedRoom.availableBeds > 0;

    return GlassmorphicSurface(
      borderRadius: BorderRadius.zero,
      blurStrength: 24.0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24.0,
          16.0,
          24.0,
          16.0 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            // Price + status
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedRoom == null ? 'Select a room' : '${selectedRoom.seaterType}-Seater',
                    style: Theme.of(context).textTheme.bodySmall!,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      selectedRoom == null
                          ? 'Choose below ↑'
                          : 'Rs. ${selectedRoom.rent.toInt()} / month',
                      key: ValueKey(selectedRoom?.seaterType),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: canBook ? AppColors.accent : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Book Now button
            _BookNowButton(
              canBook: canBook,
              onPressed: canBook ? onBookPressed : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookNowButton extends StatefulWidget {
  final bool canBook;
  final VoidCallback? onPressed;

  const _BookNowButton({required this.canBook, this.onPressed});

  @override
  State<_BookNowButton> createState() => _BookNowButtonState();
}

class _BookNowButtonState extends State<_BookNowButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (widget.canBook) _ctrl.forward(); },
      onTapUp: (_) { if (widget.canBook) { _ctrl.reverse(); widget.onPressed?.call(); } },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: widget.canBook ? AppColors.accent : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.canBook ? [] : null,
          ),
          child: Text(
            'Book Now',
            style: TextStyle(
              color: widget.canBook ? Colors.black : AppColors.textTertiary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
