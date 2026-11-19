import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class WidgetVaultProfileSelector extends StatelessWidget {
  final FamilyProvider provider;
  final int? selectedProfileId;
  final Function(int) onSelected;

  const WidgetVaultProfileSelector({
    super.key,
    required this.provider,
    required this.selectedProfileId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.profiles.isEmpty) return const SizedBox(height: 48);

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 8,
        ),
        itemCount: provider.profiles.length,
        itemBuilder: (context, index) {
          final p = provider.profiles[index];
          final isSelected = selectedProfileId == p.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p.relationship == 'Self' ? AppContent.get('vault.labels.me') : p.fullName),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  onSelected(p.id);
                }
              },
              selectedColor: Colors.white,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
      ),
    );
  }
}
