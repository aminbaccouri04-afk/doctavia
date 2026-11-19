import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/providers/provider-secretary.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/widgets/widget-user-avatar.dart';
import 'package:doctavia/core/widgets/widget-confirm-dialog.dart';
import 'package:doctavia/core/theme/theme.dart';
import './widgets/widget-profile-action.dart';

/// Profile screen for the Secretary role — mirrors the patient profile layout.
class ScreenProfileSecretary extends StatefulWidget {
  const ScreenProfileSecretary({super.key});

  @override
  State<ScreenProfileSecretary> createState() => _ScreenProfileSecretaryState();
}

class _ScreenProfileSecretaryState extends State<ScreenProfileSecretary> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SecretaryProvider>();
      if (provider.registry.isEmpty) {
        provider.fetchRegistry();
      }
      if (provider.analytics.isEmpty) {
        provider.fetchAnalytics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final secretary = context.watch<SecretaryProvider>();
    final analytics = secretary.analytics;

    final displayName = auth.currentUser?.email.split('@')[0] ?? AppContent.get('common.labels.secretaryRole');
    final todayTotal = (analytics['todayTotal'] as num?) ?? 0;
    final linkedDoctor = analytics['linkedDoctor'] as String? ?? '—';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Hero Header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            toolbarHeight: 64,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF6366F1),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => context.push('/settings'),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _SecretaryHeader(
                name: displayName,
                email: auth.currentUser?.email ?? '',
              ),
            ),
          ),

          // ─── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  _SecretaryQuickStats(
                    registered: secretary.registry.length,
                    todayTotal: todayTotal,
                    linkedDoctor: linkedDoctor,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Clinic Tools
                  Text(
                    AppContent.get('profile.secretary.clinicTools'),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  WidgetProfileAction(
                    icon: Icons.app_registration_outlined,
                    title: AppContent.get('registry.screen.title'),
                    subtitle: AppContent.get('profile.secretary.clinicToolsSub'),
                    onTap: () => context.push('/registry'),
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.bar_chart_rounded,
                    title: AppContent.get('profile.secretary.clinicAnalytics'),
                    subtitle: AppContent.get('profile.secretary.clinicAnalyticsSub'),
                    onTap: () => context.push('/stats'),
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.calendar_today_outlined,
                    title: AppContent.get('profile.secretary.appointmentsBoard'),
                    subtitle: AppContent.get('profile.secretary.appointmentsBoardSub'),
                    onTap: () => context.push('/secretary'),
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Account
                  Text(
                    AppContent.get('profile.patient.account'),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  WidgetProfileAction(
                    icon: Icons.link_outlined,
                    title: AppContent.get('profile.secretary.linkDoctor'),
                    subtitle: AppContent.get('profile.secretary.linkDoctorSub'),
                    onTap: () => _showLinkDoctorDialog(context),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.logout,
                    title: AppContent.get('profile.screen.signOut'),
                    subtitle: AppContent.get('profile.screen.signOutMessageSecretary'),
                    onTap: () async {
                      final confirmed = await WidgetConfirmDialog.show(
                        context,
                        title: AppContent.get('profile.secretary.signOutConfirm'),
                        message: AppContent.get('profile.screen.signOutMessageSecretary'),
                        confirmLabel: AppContent.get('profile.screen.signOut'),
                        isDestructive: true,
                      );
                      if (confirmed && context.mounted) {
                        await auth.logout();
                      }
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
    );
  }

  void _showLinkDoctorDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppContent.get('profile.secretary.linkDoctor')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppContent.get('profile.secretary.linkDoctorPrompt')),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: codeCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. DOC-123-456',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppContent.get('common.buttons.cancel'))),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<SecretaryProvider>().linkDoctor(codeCtrl.text.trim());
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? AppContent.get('profile.secretary.linkSuccess') : AppContent.get('profile.secretary.linkError')),
                    backgroundColor: success ? AppColors.success : AppColors.destructive,
                  ),
                );
                if (success) {
                  context.read<SecretaryProvider>().fetchAnalytics();
                }
              }
            },
            child: Text(AppContent.get('profile.secretary.linkNow')),
          ),
        ],
      ),
    );
  }
}

// ─── Private Widgets ────────────────────────────────────────────────────────

class _SecretaryHeader extends StatelessWidget {
  final String name;
  final String email;
  const _SecretaryHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  WidgetUserAvatar(
                    avatarUrl: null,
                    radius: 40,
                    fallbackIcon: Icons.badge_outlined,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppContent.get('common.labels.secretaryRole').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecretaryQuickStats extends StatelessWidget {
  final int registered;
  final num todayTotal;
  final String linkedDoctor;

  const _SecretaryQuickStats({
    required this.registered,
    required this.todayTotal,
    required this.linkedDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: registered.toString(), label: AppContent.get('profile.secretary.registered')),
          _StatDivider(),
          _StatItem(value: todayTotal.toString(), label: AppContent.get('profile.secretary.today')),
          _StatDivider(),
          _StatItem(value: linkedDoctor, label: AppContent.get('profile.secretary.drLinked'), small: true),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool small;
  const _StatItem({required this.value, required this.label, this.small = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: small
              ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        width: 1,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      );
}
