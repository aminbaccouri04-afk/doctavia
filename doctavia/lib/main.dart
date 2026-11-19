import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api-client.dart';
import 'core/services/service-storage.dart';
import 'core/services/service-notification.dart';
import 'core/theme/theme-base.dart';
import 'core/routing/routing-tree.dart';
import 'package:doctavia/core/services/service-auth.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/services/service-doctor.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/services/service-patient.dart';
import 'package:doctavia/core/providers/provider-appointment.dart';
import 'package:doctavia/core/providers/provider-specialty.dart';
import 'package:doctavia/core/providers/provider-notification.dart';
import 'package:doctavia/core/providers/provider-reminder.dart';
import 'package:doctavia/core/services/service-secretary.dart';
import 'package:doctavia/core/providers/provider-secretary.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/providers/provider-discovery.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/providers/provider-clinical.dart';
import 'package:doctavia/core/services/service-billing.dart';
import 'package:doctavia/core/providers/provider-billing.dart';
import 'package:doctavia/core/services/service-reminder.dart';
import 'package:doctavia/core/providers/provider-chat.dart';
import 'package:doctavia/core/services/service-chat.dart';
import 'package:doctavia/core/services/service-doctor-schedule.dart';
import 'package:doctavia/core/providers/provider-doctor-schedule.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app content (static text)
  await AppContent.initialize();

  // Initialize local notification service for medicine reminders
  await NotificationService.instance.init();

  // ─── Singletons ───────────────────────────────────────────────
  final storageService = StorageService();
  await storageService.init();
  final apiClient = ApiClient(storageService);
  final authService = AuthService(apiClient, storageService);
  final doctorService = DoctorService(apiClient);
  final patientService = PatientService(apiClient);
  final secretaryService = SecretaryService(apiClient);
  final billingService = BillingService(apiClient);
  final reminderService = ReminderService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) =>
              AuthProvider(authService, storageService, apiClient)
                ..tryAutoLogin(),
        ),
        ChangeNotifierProvider<DoctorProvider>(
          create: (_) => DoctorProvider(doctorService),
        ),
        ChangeNotifierProvider<FamilyProvider>(
          create: (_) => FamilyProvider(patientService)..fetchProfiles(),
        ),
        ChangeNotifierProvider<DiscoveryProvider>(
          create: (_) => DiscoveryProvider(patientService)..fetchFavorites(),
        ),
        ChangeNotifierProvider<ClinicalProvider>(
          create: (_) => ClinicalProvider(patientService),
        ),
        ChangeNotifierProvider<AppointmentProvider>(
          create: (_) =>
              AppointmentProvider(patientService)..fetchAppointments(),
        ),
        ChangeNotifierProvider<SpecialtyProvider>(
          create: (_) => SpecialtyProvider(apiClient),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(apiClient),
        ),
        ChangeNotifierProvider<SecretaryProvider>(
          create: (_) => SecretaryProvider(secretaryService),
        ),
        ChangeNotifierProvider<ReminderProvider>(
          create: (_) => ReminderProvider(reminderService)..loadReminders(),
        ),
        ChangeNotifierProvider<BillingProvider>(
          create: (_) => BillingProvider(billingService),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(chatService: ChatService()),
        ),
        ChangeNotifierProvider<DoctorScheduleProvider>(
          create: (_) =>
              DoctorScheduleProvider(DoctorScheduleService(apiClient)),
        ),
      ],
      child: const DoctaviaApp(),
    ),
  );
}

class DoctaviaApp extends StatelessWidget {
  const DoctaviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final storageService = context.watch<StorageService>();
    final router = createRouter(authProvider, storageService);

    return MaterialApp.router(
      title: AppContent.get('common.app.name'),
      debugShowCheckedModeBanner: false,
      theme: DoctaviaTheme.light(),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
