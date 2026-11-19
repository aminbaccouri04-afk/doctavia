import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';

class WidgetConsultationSoapTab extends StatelessWidget {
  final TextEditingController subjectiveCtrl;
  final TextEditingController objectiveCtrl;
  final TextEditingController assessmentCtrl;
  final TextEditingController planCtrl;
  final TextEditingController internalCtrl;

  const WidgetConsultationSoapTab({
    super.key,
    required this.subjectiveCtrl,
    required this.objectiveCtrl,
    required this.assessmentCtrl,
    required this.planCtrl,
    required this.internalCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildSoapCard(
          theme,
          title: AppContent.get('appointments.consultation.subjective'),
          hint: AppContent.get('appointments.consultation.subjectiveHint'),
          controller: subjectiveCtrl,
          icon: Icons.psychology_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSoapCard(
          theme,
          title: AppContent.get('appointments.consultation.objective'),
          hint: AppContent.get('appointments.consultation.objectiveHint'),
          controller: objectiveCtrl,
          icon: Icons.visibility_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSoapCard(
          theme,
          title: AppContent.get('appointments.consultation.assessment'),
          hint: AppContent.get('appointments.consultation.assessmentHint'),
          controller: assessmentCtrl,
          icon: Icons.fact_check_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSoapCard(
          theme,
          title: AppContent.get('appointments.consultation.plan'),
          hint: AppContent.get('appointments.consultation.planHint'),
          controller: planCtrl,
          icon: Icons.event_note_outlined,
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildSoapCard(
          theme,
          title: AppContent.get('appointments.consultation.internalNotes'),
          hint: AppContent.get('appointments.consultation.internalNotesHint'),
          controller: internalCtrl,
          icon: Icons.lock_outline_rounded,
          isPrivate: true,
        ),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }

  Widget _buildSoapCard(
    ThemeData theme, {
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPrivate = false,
  }) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isPrivate
            ? BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.2))
            : BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isPrivate ? theme.colorScheme.error : theme.colorScheme.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: isPrivate ? theme.colorScheme.error : theme.colorScheme.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPrivate ? theme.colorScheme.error : null,
                  ),
                ),
                if (isPrivate) ...[
                  const Spacer(),
                  Icon(Icons.security, size: 14, color: theme.colorScheme.error.withValues(alpha: 0.5)),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            WidgetDoctaviaInput(
              controller: controller,
              label: '',
              hint: hint,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
