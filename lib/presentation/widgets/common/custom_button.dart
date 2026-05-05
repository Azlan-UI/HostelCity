import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';


class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final bool useGradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 54,
    this.useGradient = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.width ?? double.infinity,
            height: widget.height,
            child: widget.isOutlined
                ? OutlinedButton(
                    onPressed: widget.isLoading ? null : widget.onPressed,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.backgroundColor ?? AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _buildChild(context),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: isEnabled && widget.useGradient && widget.backgroundColor == null
                          ? AppColors.primaryGradient
                          : null,
                      color: isEnabled
                          ? (widget.backgroundColor ?? (widget.useGradient ? null : AppColors.primary))
                          : AppColors.border,
                      boxShadow: isEnabled
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: widget.isLoading ? null : widget.onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _buildChild(context),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (widget.isLoading) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    final color = widget.isOutlined
        ? (widget.textColor ?? AppColors.primary)
        : (widget.textColor ?? AppColors.white);

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(widget.text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15),
    );
  }
}
