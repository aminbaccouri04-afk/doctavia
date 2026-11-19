import 'package:flutter/material.dart';
import 'package:doctavia/core/models/model-doctor.dart';
import 'package:doctavia/core/widgets/widget-user-avatar.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

/// The cinematic SliverAppBar flexible space showing the doctor's
/// avatar, name, and specialty badge.
class WidgetSearchDoctorHeader extends StatelessWidget {
  final DoctorModel doc;

  const WidgetSearchDoctorHeader({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: theme.colorScheme.surface),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.05),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: WidgetUserAvatar(
                  avatarUrl: doc.avatarUrl,
                  radius: 50,
                  fallbackIcon: Icons.medical_services,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                doc.fullName,
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (doc.specialties.isNotEmpty ? doc.specialties.first : AppContent.get('search.specialties.specialist')).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.verified, color: AppColors.info, size: 18),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
