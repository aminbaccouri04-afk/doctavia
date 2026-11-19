import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/widget-section-header.dart';
import 'package:doctavia/core/providers/provider-specialty.dart';
import './widgets/widget-home-appointment.dart';
import './widgets/widget-home-empty-appointment.dart';
import './widgets/widget-home-specialty-grid.dart';
import 'package:doctavia/features/search/widgets/widget-search-doctor-mini-card.dart';
import '../../../core/widgets/widget-user-avatar.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/providers/provider-discovery.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/providers/provider-appointment.dart'; // This is now AppointmentProvider

class ScreenHomePatient extends StatefulWidget {
  const ScreenHomePatient({super.key});

  @override
  State<ScreenHomePatient> createState() => _ScreenHomePatientState();
}

class _ScreenHomePatientState extends State<ScreenHomePatient> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final apptProv = context.read<AppointmentProvider>();
      final familyProv = context.read<FamilyProvider>();
      final discoveryProv = context.read<DiscoveryProvider>();

      try {
        // Load initial data sets in parallel
        await Future.wait([
          apptProv.fetchAppointments(),
          familyProv.fetchProfiles(),
          discoveryProv.fetchFavorites(),
        ]);
      } catch (e) {
        debugPrint('Error loading home data: $e');
      }

      if (!mounted) return;

      // Supplemental data
      context.read<SpecialtyProvider>().fetchSpecialties();

      // Nearby results
      if (discoveryProv.searchResults.isEmpty) {
        discoveryProv.searchDoctors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apptProv = context.watch<AppointmentProvider>();
    final familyProv = context.watch<FamilyProvider>();

    return WidgetScaffold(
      title: '${AppContent.get('home.patient.greeting')} ${familyProv.profiles.isNotEmpty ? familyProv.profiles.first.fullName.split(' ')[0] : AppContent.get('home.patient.defaultUser')}',
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () => context.push('/search/favorites'),
        ),
        IconButton(
          icon: const Icon(Icons.alarm),
          onPressed: () => context.push('/reminders'),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.only(right: AppSpacing.md),
          child: IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Doctavia AI', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: (apptProv.isLoading || familyProv.isLoading) && apptProv.myAppointments.isEmpty
          ? _buildLoadingState()
          : ListView(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              children: [
                _buildGreeting(theme, familyProv),
                const SizedBox(height: AppSpacing.xl),

                // ─── Upcoming Appointment ────────────────────────────
                WidgetSectionHeader(AppContent.get('home.patient.upcomingVisit')),
                const SizedBox(height: AppSpacing.md),
                _buildUpcomingAppointment(apptProv),
                const SizedBox(height: AppSpacing.xl),

                // ─── Specialty Discovery ──────────────────────────────
                WidgetSectionHeader(
                  AppContent.get('home.patient.findSpecialist'),
                  onSeeAll: () => context.go('/search'),
                  seeAllLabel: AppContent.get('home.patient.seeAll'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Consumer<SpecialtyProvider>(
                  builder: (context, specProv, _) => WidgetHomeSpecialtyGrid(
                    specialties: specProv.specialties,
                    isLoading: specProv.isLoading,
                  ),
                ),

                // ─── Nearby Highlight ────────────────────────────────
                WidgetSectionHeader(
                  AppContent.get('home.patient.nearbyDoctors'),
                  onSeeAll: () => context.go('/search'),
                  seeAllLabel: AppContent.get('home.patient.seeAll'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Consumer<DiscoveryProvider>(
                  builder: (context, discProv, _) => _buildNearbyDoctor(discProv),
                ),
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme, FamilyProvider provider) {
    if (provider.profiles.isEmpty) {
      return Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.secondary,
            child: Icon(Icons.person, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppContent.get('home.patient.greetingDefault'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(AppContent.get('home.patient.loadingMsg'), style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      );
    }

    final selfProfile = provider.profiles.firstWhere(
      (p) => p.relationship.toLowerCase() == 'self',
      orElse: () => provider.profiles.first,
    );

    return Row(
      children: [
        WidgetUserAvatar(
          avatarUrl: selfProfile.avatarUrl,
          radius: 24,
          fallbackIcon: Icons.person,
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppContent.get('home.patient.greetingDefault')} ${selfProfile.fullName.split(' ')[0]}!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  AppContent.get('home.patient.location'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointment(AppointmentProvider provider) {
    final upcoming = provider.myAppointments
        .where((a) => a.startTimeSnapshot.isAfter(DateTime.now()))
        .toList();
    if (upcoming.isEmpty) {
      return const WidgetHomeEmptyAppointment();
    }
    return WidgetHomeAppointment(appointment: upcoming.first);
  }

  Widget _buildNearbyDoctor(DiscoveryProvider provider) {
    if (provider.searchResults.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(AppContent.get('home.patient.noNearby')),
        ),
      );
    }
    return WidgetSearchDoctorMiniCard(
      doctor: provider.searchResults.first,
      onTap: () =>
          context.push('/search/doctor/${provider.searchResults.first.id}'),
      onFavoriteToggle: () =>
          provider.toggleDoctorFavorite(provider.searchResults.first.id),
    );
  }
}
