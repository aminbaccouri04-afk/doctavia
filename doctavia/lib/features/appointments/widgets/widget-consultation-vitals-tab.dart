import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';

class WidgetConsultationVitalsTab extends StatelessWidget {
  final TextEditingController bpCtrl;
  final TextEditingController hrCtrl;
  final TextEditingController tempCtrl;
  final TextEditingController weightCtrl;
  final VoidCallback? onVitalsChanged;

  const WidgetConsultationVitalsTab({
    super.key,
    required this.bpCtrl,
    required this.hrCtrl,
    required this.tempCtrl,
    required this.weightCtrl,
    this.onVitalsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                _buildVitalField(
                  AppContent.get('appointments.vitals.bloodPressure'),
                  bpCtrl,
                  '120/80',
                  AppContent.get('appointments.vitals.units.bloodPressure'),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildVitalField(
                  AppContent.get('appointments.vitals.heartRate'),
                  hrCtrl,
                  '72',
                  AppContent.get('appointments.vitals.units.heartRate'),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildVitalField(
                  AppContent.get('appointments.vitals.temperature'),
                  tempCtrl,
                  '36.6',
                  AppContent.get('appointments.vitals.units.temperature'),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildVitalField(
                  AppContent.get('appointments.vitals.weight'),
                  weightCtrl,
                  '70.5',
                  AppContent.get('appointments.vitals.units.weight'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalField(
    String label,
    TextEditingController ctrl,
    String hint,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              unit,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        WidgetDoctaviaInput(
          controller: ctrl,
          hint: hint,
          onChanged: (_) => onVitalsChanged?.call(),
        ),
      ],
    );
  }
}
