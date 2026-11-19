import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetCircleButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final double blur;
  final double opacity;

  const WidgetCircleButton({
    super.key,
    required this.icon,
    this.color,
    this.onTap,
    this.blur = 10,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            color: Colors.black.withValues(alpha: opacity),
            child: IconButton(
              icon: Icon(
                icon,
                color: color ?? AppColors.foreground,
                size: 20,
              ),
              onPressed: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
