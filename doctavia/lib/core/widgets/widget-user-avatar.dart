import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/api/api-client.dart';

/// A reusable avatar widget that displays a network image from the backend,
/// falling back to an icon if no URL is available.
class WidgetUserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double radius;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const WidgetUserAvatar({
    super.key,
    this.avatarUrl,
    this.radius = 24,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.secondaryContainer;
    final icColor = iconColor ?? theme.colorScheme.onSecondaryContainer;

    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Icon(fallbackIcon, size: radius, color: icColor),
      );
    }

    // Build the full image URL from the relative path
    final apiClient = context.read<ApiClient>();
    final serverRoot = apiClient.baseUrl.replaceAll('/api/v1', '');
    
    // If it's already a full URL (like DiceBear), use it directly
    final fullUrl = avatarUrl!.startsWith('http') 
        ? avatarUrl! 
        : '$serverRoot$avatarUrl';

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      backgroundImage: ResizeImage(
        NetworkImage(fullUrl),
        width: (radius * 3).toInt(),
        height: (radius * 3).toInt(),
      ),
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('Error loading avatar: $exception');
      },
      child: null,
    );
  }
}
