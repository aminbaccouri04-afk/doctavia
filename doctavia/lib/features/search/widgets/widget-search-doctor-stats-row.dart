import 'package:flutter/material.dart';
import 'package:doctavia/core/models/model-doctor.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-stats-card.dart';

/// The 3-tile stats row (Experience, Patients, Rating) for a doctor.
class DoctorStatsRow extends StatelessWidget {
  final DoctorModel doc;

  const DoctorStatsRow({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WidgetStatsCard(
            label: AppContent.get('search.stats.experience'),
            value: '${5 + (doc.id % 5)}${AppContent.get('search.doctorCard.years')}',
            icon: Icons.workspace_premium_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: WidgetStatsCard(
            label: AppContent.get('search.stats.patients'),
            value: '${(doc.reviewsCount * 12) + 100}+',
            icon: Icons.group_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: WidgetStatsCard(
            label: AppContent.get('search.stats.rating'),
            value: doc.rating == 0 ? AppContent.get('search.stats.new') : doc.rating.toStringAsFixed(1),
            icon: Icons.star_rounded,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}
