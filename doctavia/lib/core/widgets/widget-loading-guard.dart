import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';

/// Wraps content with a loading state guard.
/// Shows a [CircularProgressIndicator] when [isLoading] is true,
/// otherwise renders [child].
class WidgetLoadingGuard extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? indicatorColor;

  const WidgetLoadingGuard({
    super.key,
    required this.isLoading,
    required this.child,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: indicatorColor ?? AppColors.primary,
        ),
      );
    }
    return child;
  }
}
