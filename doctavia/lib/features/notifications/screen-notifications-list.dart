import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:doctavia/core/providers/provider-notification.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenNotificationsList extends StatefulWidget {
  const ScreenNotificationsList({super.key});

  @override
  State<ScreenNotificationsList> createState() => _ScreenNotificationsListState();
}

class _ScreenNotificationsListState extends State<ScreenNotificationsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('notifications.screen.title')),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text(AppContent.get('notifications.screen.markAllRead')),
            ),
        ],
      ),
      body: provider.isLoading && provider.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: provider.fetchNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final n = provider.notifications[index];
                      return _NotificationTile(notification: n)
                          ;
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 64, color: AppColors.mutedForeground.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(AppContent.get('notifications.screen.emptyTitle'), style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(AppContent.get('notifications.screen.emptySub'), style: const TextStyle(color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final SystemNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<NotificationProvider>();

    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          provider.markAsRead(notification.id);
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? Colors.transparent 
              : theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: notification.isRead 
                ? theme.dividerColor.withValues(alpha: 0.1) 
                : theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notification.isRead 
                    ? AppColors.mutedForeground.withValues(alpha: 0.1) 
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForTitle(notification.title),
                size: 20,
                color: notification.isRead ? AppColors.mutedForeground : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(notification.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: notification.isRead ? AppColors.mutedForeground : theme.textTheme.bodyMedium?.color,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('appointment') || t.contains('booking')) return Icons.calendar_today_outlined;
    if (t.contains('message') || t.contains('chat')) return Icons.chat_bubble_outline;
    if (t.contains('medical') || t.contains('result')) return Icons.description_outlined;
    return Icons.notifications_outlined;
  }
}
