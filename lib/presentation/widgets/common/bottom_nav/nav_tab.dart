import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';


class NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;
  final String? imageUrl; // For profile picture tab

  const NavTab({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 8,
          vertical: isActive ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: isActive 
            ? AppColors.accent.withValues(alpha: 0.15) 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? AppColors.accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.surfaceAlt),
                        errorWidget: (context, url, error) => Icon(Icons.person, size: 20, color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  AnimatedIconColor(
                    icon: icon,
                    color: isActive ? AppColors.accent : AppColors.textSecondary,
                    size: 24,
                  ),
                if (isActive) ...[
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            
            // Notification badge
            if (badgeCount > 0)
              Positioned(
                top: -4,
                right: -8,
                child: BadgeAnimationWidget(count: badgeCount),
              ),
          ],
        ),
      ),
    );
  }
}

class AnimatedIconColor extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AnimatedIconColor({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(color: color),
      child: Icon(icon, color: color, size: size),
    );
  }
}

class BadgeAnimationWidget extends StatefulWidget {
  final int count;

  const BadgeAnimationWidget({super.key, required this.count});

  @override
  State<BadgeAnimationWidget> createState() => _BadgeAnimationWidgetState();
}

class _BadgeAnimationWidgetState extends State<BadgeAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(BadgeAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _controller.forward(from: 0.0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          widget.count > 9 ? '9+' : widget.count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
