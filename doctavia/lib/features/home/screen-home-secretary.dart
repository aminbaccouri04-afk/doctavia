import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:doctavia/core/providers/provider-secretary.dart';
import './widgets/widget-home-queue-summary.dart';
import 'package:doctavia/features/registry/widgets/widget-registry-queue-card.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenHomeSecretary extends StatefulWidget {
  const ScreenHomeSecretary({super.key});

  @override
  State<ScreenHomeSecretary> createState() => _ScreenHomeSecretaryState();
}

class _ScreenHomeSecretaryState extends State<ScreenHomeSecretary> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecretaryProvider>().fetchRegistry();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SecretaryProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Stylized Header ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            toolbarHeight: 64,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF6366F1),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                AppContent.get('home.secretary.title'),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  ),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.hub_outlined,
                        size: 140,
                        color: Colors.white10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => provider.fetchRegistry(),
                ),
              ),
            ],
          ),

          // ─── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Summary
                  WidgetHomeQueueSummary(provider: provider),
                  const SizedBox(height: AppSpacing.xl),

                  // Section Title
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        AppContent.get('home.secretary.queueTitle'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (provider.isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (!provider.isLoading && provider.registry.isEmpty)
                    _buildEmptyState(theme)
                  else
                    ...provider.registry.map(
                      (appt) => WidgetRegistryQueueCard(
                        appt: appt,
                        provider: provider,
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppContent.get('home.secretary.checkedInMsg').replaceAll('{name}', appt.patientName ?? ''),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.huge),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppContent.get('home.secretary.noAppointments'),
              style: TextStyle(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
