import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/models/model-patient-profile.dart';
import './widgets/widget-profile-header.dart';
import './widgets/widget-profile-stats.dart';
import './widgets/widget-profile-family-card.dart';
import './widgets/widget-profile-action.dart';
import './widgets/widget-profile-sheet.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenProfilePatient extends StatefulWidget {
  const ScreenProfilePatient({super.key});

  @override
  State<ScreenProfilePatient> createState() => _ScreenProfilePatientState();
}

class _ScreenProfilePatientState extends State<ScreenProfilePatient> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<FamilyProvider>().profiles.isEmpty) {
        context.read<FamilyProvider>().fetchProfiles();
      }
    });
  }

  void _showProfileManagement({PatientProfile? profile}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => WidgetProfileSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final familyProvider = context.watch<FamilyProvider>();

    final selfProfile = familyProvider.profiles.firstWhere(
      (p) => p.relationship.toLowerCase() == 'self',
      orElse: () => PatientProfile(
        id: 0,
        accountId: 0,
        fullName: authProvider.currentUser?.email ?? AppContent.get('home.patient.greetingDefault'),
        relationship: AppContent.get('profile.patient.self'),
        dateOfBirth: '',
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Header Layer ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            toolbarHeight: 64,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: WidgetProfileHeader(profile: selfProfile),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => context.push('/settings'),
                ),
              ),
            ],
          ),

          // ─── Content Layer ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  WidgetProfileStats(),
                  const SizedBox(height: AppSpacing.xl),

                  // Family Profiles Section
                  _buildSectionHeader(
                    theme: theme,
                    title: AppContent.get('profile.patient.familyProfiles'),
                    onAdd: () => _showProfileManagement(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Family Profiles List
                  if (familyProvider.isLoading &&
                      familyProvider.profiles.isEmpty)
                    const RegistryRowShimmer()
                  else if (familyProvider.profiles.isEmpty)
                    _buildEmptyProfiles(theme)
                  else
                    ...familyProvider.profiles.map(
                      (p) => WidgetProfileFamilyCard(profile: p),
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  // Account Actions Section
                  Text(
                    AppContent.get('profile.patient.accountActions'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  WidgetProfileAction(
                    icon: Icons.folder,
                    title: AppContent.get('profile.patient.medicalRecords'),
                    subtitle: AppContent.get('profile.patient.medicalRecordsSub'),
                    onTap: () => context.push('/vault'),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.history,
                    title: AppContent.get('profile.patient.appointmentHistory'),
                    subtitle: AppContent.get('profile.patient.appointmentHistorySub'),
                    onTap: () => context.push('/bookings'),
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.receipt_long_outlined,
                    title: AppContent.get('profile.patient.billingHistory'),
                    subtitle: AppContent.get('profile.patient.billingHistorySub'),
                    onTap: () => context.push('/billing'),
                    color: Colors.orange,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.alarm_on_outlined,
                    title: 'Health Reminders',
                    subtitle: 'Manage medication and follow-ups',
                    onTap: () => context.push('/reminders'),
                    color: Colors.teal,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.logout,
                    title: AppContent.get('profile.screen.signOut'),
                    subtitle: AppContent.get('profile.screen.signOutMessage'),
                    onTap: () async {
                      await authProvider.logout();
                    },
                    color: theme.colorScheme.error,
                  ),

                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: familyProvider.errorMessage != null
          ? _buildErrorBar(familyProvider)
          : null,
    );
  }

  Widget _buildSectionHeader({
    required ThemeData theme,
    required String title,
    required VoidCallback onAdd,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(AppContent.get('common.buttons.add')),
        ),
      ],
    );
  }

  Widget _buildEmptyProfiles(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.family_restroom,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppContent.get('profile.patient.noFamily'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppContent.get('profile.patient.noFamilySub'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => _showProfileManagement(),
            icon: const Icon(Icons.add),
            label: Text(AppContent.get('profile.patient.addFamily')),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBar(FamilyProvider provider) {
    return Material(
      color: AppColors.destructive,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => provider.clearError(),
            ),
          ],
        ),
      ),
    );
  }
}
