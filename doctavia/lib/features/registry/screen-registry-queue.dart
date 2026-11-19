import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';

class ScreenRegistryQueue extends StatefulWidget {
  const ScreenRegistryQueue({super.key});

  @override
  State<ScreenRegistryQueue> createState() => _ScreenRegistryQueueState();
}

class _ScreenRegistryQueueState extends State<ScreenRegistryQueue> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().fetchSchedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DoctorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('registry.screen.queueTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchSchedule(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const ShimmerList(child: RegistryRowShimmer())
          : provider.errorMessage != null
          ? Center(
              child: Text(
                provider.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            )
          : provider.appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppContent.get('registry.screen.noQueue'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: provider.appointments.length,
              itemBuilder: (context, index) {
                final appt = provider.appointments[index];
                final isConfirmed = appt.status == 'confirmed';

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                appt.patientName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'P',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appt.patientName ?? AppContent.get('registry.card.unknownPatient'),
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    AppContent.get('registry.card.at')
                                        .replaceAll('{date}', DateFormat.yMMMd().format(appt.startTimeSnapshot))
                                        .replaceAll('{time}', DateFormat.jm().format(appt.startTimeSnapshot)),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(
                                appt.status == 'checked_in' 
                                    ? AppContent.get('registry.card.checkedIn') 
                                    : appt.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isConfirmed
                                      ? AppColors.success
                                      : theme.colorScheme.error,
                                ),
                              ),
                              backgroundColor: isConfirmed
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : theme.colorScheme.error.withValues(
                                      alpha: 0.1,
                                    ),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        if (appt.status == 'checked_in' ||
                            appt.status == 'confirmed') ...[
                          const Divider(height: AppSpacing.lg),
                          OverflowBar(
                            alignment: MainAxisAlignment.end,
                            spacing: AppSpacing.sm,
                            children: [
                              TextButton(
                                onPressed: () => context.push('/vault/trends/${appt.patientProfileId}'),
                                child: Text(AppContent.get('registry.screen.viewVault')),
                              ),
                              ElevatedButton(
                                onPressed: () => context.push(
                                  '/consultation/${appt.id}',
                                  extra: appt,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appt.status == 'checked_in'
                                      ? AppColors.primary
                                      : null,
                                  foregroundColor: appt.status == 'checked_in'
                                      ? Colors.white
                                      : null,
                                ),
                                child: Text(AppContent.get('registry.screen.startConsultation')),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
