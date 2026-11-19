import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-secretary.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-charts.dart';

class ScreenSecretaryStats extends StatefulWidget {
  const ScreenSecretaryStats({super.key});

  @override
  State<ScreenSecretaryStats> createState() => _ScreenSecretaryStatsState();
}

class _ScreenSecretaryStatsState extends State<ScreenSecretaryStats> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecretaryProvider>().fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SecretaryProvider>();
    final analytics = provider.analytics;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('profile.secretary.clinicAnalytics')),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _buildStatCard(
                  theme,
                  title: 'Today\'s Throughput',
                  value: '${analytics['todayTotal'] ?? 0}',
                  subtitle: 'Completed: ${analytics['todayCompleted'] ?? 0}',
                  icon: Icons.speed_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildStatCard(
                  theme,
                  title: 'Clinic Volume (30 Days)',
                  value: '${analytics['monthlyVolume'] ?? 0}',
                  subtitle: 'Average per day: ${((analytics['monthlyVolume'] ?? 0) / 30).toStringAsFixed(1)}',
                  icon: Icons.analytics_outlined,
                  color: Colors.indigo,
                ),
                const SizedBox(height: AppSpacing.huge),
                Text(
                  'Daily Volume Trend',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 250,
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: DoctaviaLineChart(
                        title: '',
                        data: (analytics['dailyTrend'] as List? ?? []).map((e) {
                          return ChartDataPoint(
                            label: e['date'].toString().substring(5), // MM-DD
                            value: double.tryParse(e['count'].toString()) ?? 0.0,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelMedium?.copyWith(color: AppColors.mutedForeground)),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
