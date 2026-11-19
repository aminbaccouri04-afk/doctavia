import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/widget-user-avatar.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetHomeAppointment extends StatelessWidget {
  final Appointment appointment;

  const WidgetHomeAppointment({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: const BoxDecoration(
        boxShadow: AppShadows.brand,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, d MMMM y').format(appointment.startTimeSnapshot),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat.jm().format(appointment.startTimeSnapshot)} - ${DateFormat.jm().format(appointment.startTimeSnapshot.add(const Duration(minutes: 30)))}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: WidgetUserAvatar(
                            avatarUrl: appointment.doctorAvatarUrl,
                            radius: 20,
                            fallbackIcon: Icons.medical_services,
                          ),
                          title: Text(
                            appointment.doctorName ?? AppContent.get('home.appointment.defaultDoctor'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text(AppContent.get('home.appointment.upcoming'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          trailing: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
