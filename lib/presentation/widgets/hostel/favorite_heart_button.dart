import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';


class FavoriteHeartButton extends StatefulWidget {
  final String hostelId;
  final bool initialFavorite;
  final VoidCallback onTap;

  const FavoriteHeartButton({
    super.key,
    required this.hostelId,
    this.initialFavorite = false,
    required this.onTap,
  });

  @override
  State<FavoriteHeartButton> createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<FavoriteHeartButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialFavorite;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _onHeartTap() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    if (_isFavorite) {
      _controller.forward(from: 0.0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onHeartTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Burst particles
            ..._buildBurstParticles(),
            
            // Heart icon with scale animation
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.4).animate(
                CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBurstParticles() {
    return List.generate(8, (index) {
      final angle = (index / 8) * 2 * pi;
      final distance = 30.0;
      final endX = cos(angle) * distance;
      final endY = sin(angle) * distance;
      
      return Positioned(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 0.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            ),
            child: Transform.translate(
              offset: Offset(endX, endY),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
