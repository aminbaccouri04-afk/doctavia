import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

enum DoctaviaButtonVariant { primary, secondary, outline, destructive, ghost }

class WidgetDoctaviaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final DoctaviaButtonVariant variant;
  final IconData? icon;
  final double? height;

  const WidgetDoctaviaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = DoctaviaButtonVariant.primary,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;

    // Resolve Colors
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case DoctaviaButtonVariant.primary:
        bg = theme.colorScheme.primary;
        fg = Colors.white;
        break;
      case DoctaviaButtonVariant.secondary:
        bg = AppColors.secondary;
        fg = theme.colorScheme.primary;
        break;
      case DoctaviaButtonVariant.outline:
        bg = Colors.transparent;
        fg = theme.colorScheme.primary;
        border = BorderSide(color: theme.colorScheme.primary, width: 1.5);
        break;
      case DoctaviaButtonVariant.destructive:
        bg = theme.colorScheme.error;
        fg = Colors.white;
        break;
      case DoctaviaButtonVariant.ghost:
        bg = Colors.transparent;
        fg = theme.colorScheme.primary;
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 56,
      child:
          ElevatedButton(
                onPressed: isDisabled
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onPressed?.call();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: fg,
                  disabledBackgroundColor: bg.withValues(alpha: 0.6),
                  elevation: 0,
                  side: border,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                ),
                child: content,
              )
              .animate(target: isLoading ? 1 : 0)
              .shimmer(duration: 1200.ms, color: Colors.white24),
    );
  }
}
