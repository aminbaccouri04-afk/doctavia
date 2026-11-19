import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';

class ScreenSettingsHelp extends StatelessWidget {
  const ScreenSettingsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('settings.help.title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            AppContent.get('settings.help.greeting'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          WidgetDoctaviaInput(
            label: '',
            hint: AppContent.get('settings.help.searchHint'),
          ),
          const SizedBox(height: 32),
          _buildHelpSection(AppContent.get('settings.help.popularTopics')),
          _buildHelpTile(AppContent.get('settings.help.topicBooking')),
          _buildHelpTile(AppContent.get('settings.help.topicVault')),
          _buildHelpTile(AppContent.get('settings.help.topicPassword')),
          _buildHelpTile(AppContent.get('settings.help.topicBilling')),
          const SizedBox(height: 24),
          _buildHelpSection(AppContent.get('settings.help.contactSupport')),
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.headset_mic_outlined, size: 40, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text(AppContent.get('settings.help.stillNeedHelp'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(AppContent.get('settings.help.supportAvail'), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  WidgetDoctaviaButton(
                    text: AppContent.get('settings.help.contactUs'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.mutedForeground),
      ),
    );
  }

  Widget _buildHelpTile(String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding: EdgeInsets.zero,
      onTap: () {},
    );
  }
}

