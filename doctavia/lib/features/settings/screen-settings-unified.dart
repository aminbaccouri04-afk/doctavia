import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';
import 'package:doctavia/core/widgets/widget-confirm-dialog.dart';
import 'package:doctavia/core/widgets/widget-settings-tiles.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/services/service-notification.dart';

class ScreenSettingsUnified extends StatefulWidget {
  const ScreenSettingsUnified({super.key});

  @override
  State<ScreenSettingsUnified> createState() => _ScreenSettingsUnifiedState();
}

class _ScreenSettingsUnifiedState extends State<ScreenSettingsUnified> {
  bool _hasExactAlarmPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final has = await NotificationService.instance.hasExactAlarmPermission();
    if (mounted) {
      setState(() => _hasExactAlarmPermission = has);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('settings.screen.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          WidgetSettingsSectionHeader(
            title: AppContent.get('settings.screen.accountProfile'),
          ),
          WidgetSettingsTile(
            icon: Icons.person_outline,
            title: AppContent.get('settings.screen.editProfile'),
            onTap: () => context.push('/settings/profile'),
          ),
          WidgetSettingsTile(
            icon: Icons.lock_outline,
            title: AppContent.get('settings.screen.security'),
            onTap: () => context.push('/settings/security'),
          ),
          const Divider(),

          WidgetSettingsSectionHeader(
            title: AppContent.get('notifications.permission.title'),
          ),
          WidgetSettingsTile(
            icon: Icons.alarm,
            title: AppContent.get('notifications.permission.exactAlarm'),
            trailing: _hasExactAlarmPermission
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : const Icon(Icons.error, color: AppColors.destructive),
            onTap: () async {
              await NotificationService.instance.requestExactAlarmPermission();
              _checkPermissions();
            },
          ),
          const Divider(),

          WidgetSettingsSectionHeader(
            title: AppContent.get('settings.screen.supportLegal'),
          ),
          WidgetSettingsTile(
            icon: Icons.help_outline,
            title: AppContent.get('settings.screen.helpCenter'),
            onTap: () => context.push('/settings/help'),
          ),
          WidgetSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: AppContent.get('settings.screen.privacyPolicy'),
            onTap: () => context.push('/settings/privacy'),
          ),
          WidgetSettingsTile(
            icon: Icons.notification_important_outlined,
            title: AppContent.get('common.app.testNotification'),
            onTap: () async {
              await NotificationService.instance.testNotification();
            },
          ),
          const Divider(),

          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: WidgetDoctaviaButton(
              text: AppContent.get('profile.screen.signOut'),
              variant: DoctaviaButtonVariant.outline,
              onPressed: () async {
                final confirmed = await WidgetConfirmDialog.show(
                  context,
                  title: AppContent.get('profile.screen.signOutConfirm'),
                  message: AppContent.get('profile.screen.signOutMessage'),
                  confirmLabel: AppContent.get('profile.screen.signOut'),
                  isDestructive: true,
                );

                if (confirmed == true && context.mounted) {
                  await authProvider.logout();
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              AppContent.get('settings.screen.version'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
