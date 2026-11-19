import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';

class WidgetHomeSpecialtyGrid extends StatelessWidget {
  final List<dynamic> specialties;
  final bool isLoading;

  const WidgetHomeSpecialtyGrid({
    super.key,
    required this.specialties,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && specialties.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: SpecialtyPillShimmer()),
      );
    }

    final displayItems = specialties.take(6).toList();
    
    final icons = {
      'General': Icons.medical_services_outlined,
      'Cardiology': Icons.favorite_outline,
      'Neurology': Icons.psychology_outlined,
      'Pediatrics': Icons.child_care,
      'Dentistry': Icons.health_and_safety_outlined,
      'Dermatology': Icons.face_retouching_natural,
    };
    
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: displayItems.map((spec) => 
          _buildSpecItem(
            context,
            spec.name,
            icons[spec.name] ?? Icons.medical_services_outlined,
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildSpecItem(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: InkWell(
        onTap: () => context.go('/search?specialty=$label'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.secondary,
              child: Icon(icon, color: theme.colorScheme.onSecondaryContainer, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
