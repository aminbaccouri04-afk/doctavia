import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/models/model-prescription.dart';

class WidgetVaultPrescriptionCard extends StatelessWidget {
  final PrescriptionModel prescription;

  const WidgetVaultPrescriptionCard({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: WidgetCard(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  prescription.medicationName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    prescription.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildRow(Icons.science_outlined, AppContent.get('vault.labels.dosage'), prescription.dosage),
            _buildRow(Icons.repeat, AppContent.get('vault.labels.frequency'), prescription.frequency),
            _buildRow(
              Icons.calendar_today_outlined,
              AppContent.get('vault.labels.duration'),
              prescription.duration,
            ),
            if (prescription.instructions != null)
              _buildRow(
                Icons.info_outline,
                AppContent.get('vault.labels.instructions'),
                prescription.instructions!,
              ),
            const SizedBox(height: 8),
            Text(
              AppContent.get('vault.prescriptions.issuedOn').replaceAll('{date}', DateFormat.yMMMd().format(prescription.createdAt)),
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.mutedForeground),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
