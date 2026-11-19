import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';

/// A consistent section heading used across screens
/// (search-details, vault, home, analytics).
class WidgetSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onSeeAll;
  final String? seeAllLabel;

  const WidgetSectionHeader(
    this.title, {
    super.key,
    this.trailing,
    this.onSeeAll,
    this.seeAllLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              seeAllLabel ?? 'See All',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          )
        else
          trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

/// Smaller sub-section label used inside cards and lists.
class SubSectionHeader extends StatelessWidget {
  final String title;

  const SubSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
