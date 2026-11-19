import 'package:go_router/go_router.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/services/service-storage.dart';
import '../../features/auth/screen-onboarding.dart';
import '../../features/auth/screen-auth-login.dart';
import '../../features/auth/screen-auth-signup.dart';
import '../../features/billing/screen-billing-invoices.dart';
import '../../features/home/screen-home-doctor.dart';
import '../../features/appointments/screen-appointments-schedule.dart';
import '../../features/registry/screen-registry-queue.dart';
import '../../features/appointments/screen-appointments-consultation.dart';
import '../../features/profile/screen-profile-doctor.dart';
import '../../features/settings/screen-settings-unified.dart';
import '../../features/settings/screen-settings-security.dart';
import '../../features/settings/screen-settings-help.dart';
import '../../features/settings/screen-settings-privacy.dart';
import '../../features/settings/screen-settings-change-password.dart';
import '../../features/settings/screen-settings-staff.dart';
import '../../features/profile/screen-profile-edit.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import '../../features/home/screen-home-patient.dart';
import '../../features/search/screen-search-list.dart';
import '../../features/search/screen-search-details.dart';
import '../../features/profile/screen-profile-patient.dart';
import '../../features/vault/screen-vault-dashboard.dart';
import '../../features/appointments/screen-appointments-bookings.dart';
import '../../features/notifications/screen-notifications-list.dart';
import '../../features/search/screen-search-favorites.dart';
import '../../features/appointments/screen-appointments-review.dart';

import '../../features/profile/screen-doctor-offices.dart';
import '../../features/profile/screen-doctor-edit-professional.dart';
import '../../features/registry/screen-secretary-stats.dart';
// Unified settings imported above
import '../../features/search/screen-search-map.dart';
import '../../features/reminders/screen-reminders-list.dart';
import '../../features/reminders/screen-reminders-add.dart';
import '../../features/home/screen-home-secretary.dart';
import '../../features/registry/screen-registry-dashboard.dart';
// Unified settings imported above
// Unified settings imported above
import '../../features/profile/screen-profile-secretary.dart';
import '../../features/board/widget-board-shell.dart';
import '../../features/chat/screen-chat.dart';
import 'package:doctavia/features/settings/screen-settings-working-hours.dart';

/// Declarative router with auth guards and role-based landing pages.
GoRouter createRouter(AuthProvider authProvider, StorageService storageService) {
  return GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final isAuth = authProvider.isAuthenticated;
      final onboardingCompleted = storageService.getBool('onboarding_completed') ?? false;

      // ─── Onboarding Guard ─────────────────────────────────────
      if (!onboardingCompleted && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }

      // If onboarding is done but trying to access it, go to login or home
      if (onboardingCompleted && state.matchedLocation == '/onboarding') {
        return isAuth ? _roleHome(authProvider.userRole) : '/login';
      }

      final isPublicRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/onboarding';

      // Not authenticated → force to login (unless already there)
      if (!isAuth && !isPublicRoute) return '/login';

      // Authenticated but on auth page → redirect to role home
      if (isAuth && isPublicRoute) {
        return _roleHome(authProvider.userRole);
      }

      // ─── Role-Based Access Control ────────────────────────────
      if (isAuth) {
        final role = authProvider.userRole;
        final loc = state.matchedLocation;

        // Patient-only routes
        const patientRoutes = ['/home', '/search', '/bookings', '/profile', '/vault', '/map', '/reminders', '/billing', '/waiting-room', '/chat'];
        // Doctor-only routes
        const doctorRoutes = ['/dashboard', '/schedule', '/patients', '/consultation', '/doctor'];
        // Secretary-only routes
        const secretaryRoutes = ['/secretary', '/registry'];

        if (role == 'secretary' && patientRoutes.any((r) => loc.startsWith(r))) {
          return '/secretary';
        }
        if (role == 'secretary' && doctorRoutes.any((r) => loc.startsWith(r))) {
          return '/secretary';
        }
        if (role == 'patient' && doctorRoutes.any((r) => loc.startsWith(r))) {
          return '/home';
        }
        if (role == 'patient' && secretaryRoutes.any((r) => loc.startsWith(r))) {
          return '/home';
        }
        if (role == 'doctor' && patientRoutes.any((r) => loc.startsWith(r))) {
          return '/dashboard';
        }
        if (role == 'doctor' && secretaryRoutes.any((r) => loc.startsWith(r))) {
          return '/dashboard';
        }
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const ScreenOnboarding(),
      ),
      // ─── Auth Routes ──────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const ScreenAuthLogin(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const ScreenAuthSignup(),
      ),

      // ─── Patient Shell ────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppBoard(
          role: 'patient',
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const ScreenHomePatient(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) {
              final specialty = state.uri.queryParameters['specialty'];
              return ScreenSearchList(initialSpecialty: specialty);
            },
            routes: [
              GoRoute(
                path: 'doctor/:id',
                builder: (context, state) => ScreenSearchDetails(doctorId: int.parse(state.pathParameters['id']!)),
              ),
              GoRoute(
                path: 'favorites',
                builder: (context, state) => const ScreenSearchFavorites(),
              ),
            ]
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const ScreenAppointmentsBookings(),
            routes: [
              GoRoute(
                path: 'review/:id/:name',
                builder: (context, state) => ScreenAppointmentsReview(
                  appointmentId: int.parse(state.pathParameters['id']!),
                  doctorName: state.pathParameters['name']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ScreenProfilePatient(),
          ),
          GoRoute(
            path: '/vault',
            builder: (context, state) => const ScreenVaultDashboard(),
            routes: [

            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const ScreenSettingsUnified(),
            routes: [
              GoRoute(path: 'profile', builder: (context, state) => const ScreenProfileEdit()),
              GoRoute(path: 'security', builder: (context, state) => const ScreenSettingsSecurity()),
              GoRoute(path: 'change-password', builder: (context, state) => const ScreenSettingsChangePassword()),
              GoRoute(path: 'help', builder: (context, state) => const ScreenSettingsHelp()),
              GoRoute(path: 'privacy', builder: (context, state) => const ScreenSettingsPrivacy()),
            ],
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const ScreenSearchMap(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const ScreenNotificationsList(),
          ),
          GoRoute(
            path: '/reminders',
            builder: (context, state) => const ScreenRemindersList(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const ScreenRemindersAdd(),
              ),
            ],
          ),
          GoRoute(
            path: '/billing',
            builder: (context, state) => const ScreenBillingInvoices(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ScreenChat(),
          ),
        ],
      ),

      // ─── Doctor Shell ─────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppBoard(
          role: 'doctor',
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const ScreenHomeDoctor(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScreenAppointmentsSchedule(),
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) => const ScreenRegistryQueue(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const ScreenSettingsUnified(),
            routes: [
              GoRoute(path: 'profile', builder: (context, state) => const ScreenProfileEdit()),
              GoRoute(path: 'security', builder: (context, state) => const ScreenSettingsSecurity()),
              GoRoute(path: 'change-password', builder: (context, state) => const ScreenSettingsChangePassword()),
              GoRoute(path: 'help', builder: (context, state) => const ScreenSettingsHelp()),
              GoRoute(path: 'privacy', builder: (context, state) => const ScreenSettingsPrivacy()),
              GoRoute(path: 'working-hours', builder: (context, state) => const ScreenSettingsWorkingHours()),
              GoRoute(path: 'staff', builder: (context, state) => const ScreenSettingsStaff()),
            ],
          ),
          GoRoute(
            path: '/consultation/:apptId',
            builder: (context, state) {
              final appt = state.extra as Appointment;
              return ScreenAppointmentsConsultation(appointment: appt);
            },
          ),
          GoRoute(
            path: '/doctor/profile',
            builder: (context, state) => const ScreenProfileDoctor(),
            routes: [
              GoRoute(
                path: 'offices',
                builder: (context, state) => const ScreenDoctorOffices(),
              ),
              GoRoute(
                path: 'edit-professional',
                builder: (context, state) => const ScreenDoctorEditProfessional(),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const ScreenNotificationsList(),
          ),
        ],
      ),

      // ─── Secretary Shell ──────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppBoard(
          role: 'secretary',
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/secretary',
            builder: (context, state) => const ScreenHomeSecretary(),
          ),
          GoRoute(
            path: '/registry',
            builder: (context, state) => const ScreenRegistryDashboard(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const ScreenSecretaryStats(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const ScreenSettingsUnified(),
            routes: [
              GoRoute(path: 'profile', builder: (context, state) => const ScreenProfileEdit()),
              GoRoute(path: 'security', builder: (context, state) => const ScreenSettingsSecurity()),
              GoRoute(path: 'change-password', builder: (context, state) => const ScreenSettingsChangePassword()),
              GoRoute(path: 'help', builder: (context, state) => const ScreenSettingsHelp()),
              GoRoute(path: 'privacy', builder: (context, state) => const ScreenSettingsPrivacy()),
            ],
          ),
          GoRoute(
            path: '/secretary/profile',
            builder: (context, state) => const ScreenProfileSecretary(),
          ),
        ],
      ),
    ],
  );
}

/// Returns the home route for a given role.
String _roleHome(String? role) {
  switch (role) {
    case 'doctor':
      return '/dashboard';
    case 'secretary':
      return '/secretary';
    case 'patient':
    default:
      return '/home';
  }
}
