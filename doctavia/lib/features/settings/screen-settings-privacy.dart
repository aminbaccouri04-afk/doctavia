import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenSettingsPrivacy extends StatelessWidget {
  const ScreenSettingsPrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('settings.privacy.title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppContent.get('settings.privacy.title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(AppContent.get('settings.privacy.lastUpdated'), style: const TextStyle(color: AppColors.mutedForeground)),
            const SizedBox(height: 24),
            _buildParagraph(AppContent.get('settings.privacy.intro')),
            _buildSectionHeader(AppContent.get('settings.privacy.section1')),
            _buildParagraph(AppContent.get('settings.privacy.content1')),
            _buildSectionHeader(AppContent.get('settings.privacy.section2')),
            _buildParagraph(AppContent.get('settings.privacy.content2')),
            _buildSectionHeader(AppContent.get('settings.privacy.section3')),
            _buildParagraph(AppContent.get('settings.privacy.content3')),
            _buildSectionHeader(AppContent.get('settings.privacy.section4')),
            _buildParagraph(AppContent.get('settings.privacy.content4')),
            const SizedBox(height: 40),
            Center(
              child: Text(
                AppContent.get('settings.privacy.footer'),
                style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.foreground),
    );
  }
}
