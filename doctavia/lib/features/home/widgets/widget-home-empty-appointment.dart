import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetHomeEmptyAppointment extends StatelessWidget {
  const WidgetHomeEmptyAppointment({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.huge,
            ),
            child: Column(
              children: [
                // ─── Decorative Icon Stack ────────────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 40,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ─── Header ─────────────────────────────────────
                Text(
                  'No Upcoming Visits',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ─── Supportive Text ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Text(
                    'Regular check-ups are key to maintaining your long-term health.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ─── CTA Button ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/search'),
                    icon: const Icon(Icons.add_task),
                    label: Text(AppContent.get('home.patient.bookNow')),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
