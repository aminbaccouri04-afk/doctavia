import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-clinical.dart';
import 'package:doctavia/features/vault/widgets/widget-vault-prescription-card.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/core/widgets/widget-empty-state.dart';
import 'package:doctavia/core/providers/provider-content.dart';

/// The "Prescriptions" tab content for the Medical Vault screen.
class WidgetVaultPrescriptionsTab extends StatelessWidget {
  final ClinicalProvider provider;

  const WidgetVaultPrescriptionsTab({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.prescriptions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        child: ShimmerList(itemCount: 4, child: RecordCardShimmer()),
      );
    }
    if (provider.prescriptions.isEmpty) {
      return WidgetEmptyState(
        icon: Icons.medication_liquid_outlined,
        title: AppContent.get('vault.prescriptions.noData'),
        subtitle: AppContent.get('vault.prescriptions.noDataSub'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      itemCount: provider.prescriptions.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => WidgetVaultPrescriptionCard(prescription: provider.prescriptions[index]),
    );
  }
}
