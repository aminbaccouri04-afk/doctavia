import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/core/providers/provider-secretary.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-empty-state.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';

class ScreenRegistryDashboard extends StatefulWidget {
  const ScreenRegistryDashboard({super.key});

  @override
  State<ScreenRegistryDashboard> createState() => _ScreenRegistryDashboardState();
}

class _ScreenRegistryDashboardState extends State<ScreenRegistryDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecretaryProvider>().fetchRegistry();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecretaryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('registry.screen.title')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: WidgetDoctaviaInput(
              label: '',
              hint: AppContent.get('registry.screen.searchHint'),
            ),
          ),
        ),
      ),
      body: provider.isLoading && provider.registry.isEmpty
          ? const ShimmerList(child: RegistryRowShimmer())
          : provider.registry.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: provider.registry.length,
                  itemBuilder: (context, index) {
                    final appt = provider.registry[index];
                    return _RegistryCard(appointment: appt);
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return WidgetEmptyState(
      icon: Icons.assignment_ind_outlined,
      title: AppContent.get('registry.screen.noPatients'),
      action: WidgetDoctaviaButton(
        text: AppContent.get('registry.screen.refresh'),
        onPressed: () => context.read<SecretaryProvider>().fetchRegistry(),
        variant: DoctaviaButtonVariant.outline,
      ),
    );
  }
}

class _RegistryCard extends StatefulWidget {
  final dynamic appointment;

  const _RegistryCard({required this.appointment});

  @override
  State<_RegistryCard> createState() => _RegistryCardState();
}

class _RegistryCardState extends State<_RegistryCard> {
  bool _isCheckingIn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appointment = widget.appointment;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    appointment.patientName?.substring(0, 1).toUpperCase() ?? 'P',
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName ?? AppContent.get('registry.card.unknownPatient'), 
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppContent.get('registry.card.withDoctor').replaceAll('{name}', appointment.doctorName ?? AppContent.get('common.labels.doctorRole')),
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat.jm().format(appointment.startTimeSnapshot),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppContent.get('registry.card.slot').split(':')[0],
                      style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(height: 1, thickness: 0.5),
            ),
            WidgetDoctaviaButton(
              text: AppContent.get('registry.screen.checkIn'),
              isFullWidth: true,
              height: 44,
              variant: DoctaviaButtonVariant.secondary,
              isLoading: _isCheckingIn,
              onPressed: () async {
                setState(() => _isCheckingIn = true);
                final prov = context.read<SecretaryProvider>();
                final success = await prov.checkInPatient(appointment.id);
                
                if (!mounted) return;
                setState(() => _isCheckingIn = false);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppContent.get('registry.screen.checkInSuccess')), 
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
