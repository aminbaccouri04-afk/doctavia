import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenSettingsSecurity extends StatelessWidget {
  const ScreenSettingsSecurity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('settings.security.title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSecurityTile(
            context,
            icon: Icons.password_outlined,
            title: AppContent.get('settings.security.changePassword'),
            subtitle: AppContent.get('settings.security.lastChanged'),
            onTap: () => context.push('/settings/change-password'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: titleColor)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
