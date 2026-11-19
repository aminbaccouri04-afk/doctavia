import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/core/providers/provider-appointment.dart';
import 'package:doctavia/features/appointments/widgets/widget-appointment-card.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-empty-state.dart';

class ScreenAppointmentsBookings extends StatefulWidget {
  const ScreenAppointmentsBookings({super.key});

  @override
  State<ScreenAppointmentsBookings> createState() => _ScreenAppointmentsBookingsState();
}

class _ScreenAppointmentsBookingsState extends State<ScreenAppointmentsBookings>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().fetchAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final appointments = provider.myAppointments;

    final upcoming = appointments
        .where((a) => a.status == 'pending' || a.status == 'confirmed' || a.status == 'checked_in' || a.status == 'in_progress')
        .toList();
    final past = appointments
        .where((a) => a.status == 'completed' || a.status == 'cancelled')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('appointments.list.title')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppContent.get('appointments.list.upcoming')),
            Tab(text: AppContent.get('appointments.list.past')),
          ],
        ),
      ),
      body: provider.isLoading && appointments.isEmpty
          ? const ShimmerList(child: WidgetShimmerAppointment())
          : TabBarView(
              controller: _tabController,
              children: [
                _AppointmentList(
                  appointments: upcoming,
                  emptyMsg: AppContent.get('appointments.list.noUpcoming'),
                ),
                _AppointmentList(
                  appointments: past,
                  emptyMsg: AppContent.get('appointments.list.noPast'),
                ),
              ],
            ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Appointment> appointments;
  final String emptyMsg;

  const _AppointmentList({required this.appointments, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return WidgetEmptyState(
        icon: Icons.calendar_today_outlined,
        title: emptyMsg,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: appointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return WidgetAppointmentCard(appointment: appt);
      },
    );
  }
}
