import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import '../../../core/widgets/widget-user-avatar.dart';
import 'package:doctavia/core/models/model-patient-profile.dart';
import './widget-profile-sheet.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetProfileFamilyCard extends StatelessWidget {
  final PatientProfile profile;

  const WidgetProfileFamilyCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelf = profile.relationship.toLowerCase() == 'self';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: WidgetCard(
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppSpacing.md),
          leading: WidgetUserAvatar(
            avatarUrl: profile.avatarUrl,
            radius: 25,
            fallbackIcon: isSelf ? Icons.person : Icons.family_restroom,
            backgroundColor: isSelf 
                ? theme.colorScheme.primaryContainer 
                : theme.colorScheme.secondaryContainer,
            iconColor: isSelf 
                ? theme.colorScheme.onPrimaryContainer 
                : theme.colorScheme.onSecondaryContainer,
          ),
          title: Text(
            profile.fullName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                AppContent.get('profile.family.dob').replaceAll('{date}', profile.dateOfBirth),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Chip(
                label: Text(
                  AppContent.translateRelationship(profile.relationship).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold,
                    color: isSelf 
                        ? theme.colorScheme.onPrimaryContainer 
                        : theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: isSelf 
                    ? theme.colorScheme.primaryContainer 
                    : theme.colorScheme.secondaryContainer,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
            onSelected: (value) async {
              if (value == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) => WidgetProfileSheet(profile: profile),
                );
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppContent.get('profile.family.deleteProfile')),
                    content: Text(AppContent.get('profile.family.deleteConfirm').replaceAll('{name}', profile.fullName)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppContent.get('common.buttons.cancel'))),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppContent.get('common.labels.delete'), style: const TextStyle(color: AppColors.destructive))),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await context.read<FamilyProvider>().deleteProfile(profile.id);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 18),
                    const SizedBox(width: 8),
                    Text(AppContent.get('common.buttons.edit')),
                  ],
                ),
              ),
              if (!isSelf) PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppColors.destructive),
                    SizedBox(width: 8),
                    Text(AppContent.get('common.labels.delete'), style: const TextStyle(color: AppColors.destructive)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
