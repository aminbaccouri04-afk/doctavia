import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/widgets/widget-snackbar.dart';
import 'package:doctavia/core/widgets/widget-section-header.dart';
import 'package:doctavia/core/providers/provider-discovery.dart';
import 'package:doctavia/core/providers/provider-appointment.dart'; // Still needed for profile list
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/models/model-doctor.dart';
import 'package:doctavia/features/appointments/widgets/widget-appointment-booking-sheet.dart';
import 'package:doctavia/features/appointments/widgets/widget-appointment-slot-grid.dart';
import 'package:doctavia/features/search/widgets/widget-search-doctor-header.dart';
import 'package:doctavia/features/search/widgets/widget-search-doctor-stats-row.dart';
import 'package:doctavia/features/search/widgets/widget-search-date-strip.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';
import 'package:doctavia/core/widgets/widget-circle-button.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenSearchDetails extends StatefulWidget {
  final int doctorId;

  const ScreenSearchDetails({super.key, required this.doctorId});

  @override
  State<ScreenSearchDetails> createState() => _ScreenSearchDetailsState();
}

class _ScreenSearchDetailsState extends State<ScreenSearchDetails> {
  bool _isInitLoaded = false;
  DateTime? _selectedDate;
  int? _selectedSlotId;
  int? _selectedOfferingId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final discovery = context.read<DiscoveryProvider>();
    final exists = discovery.searchResults.any((d) => d.id == widget.doctorId);
    if (!exists) {
      await discovery.fetchDoctorById(widget.doctorId);
    }
    if (mounted) setState(() => _isInitLoaded = true);
  }

  void _showBookingSheet(BuildContext context, DiscoveryProvider discovery, FamilyProvider family, AppointmentProvider appointment, DoctorModel doc, int slotId) {
    if (family.profiles.isEmpty) {
      WidgetSnackbar.show(context, AppContent.get('search.screen.loadingProfiles'));
      return;
    }
    final offering = _selectedOfferingId != null 
        ? doc.offerings.firstWhere((s) => s.id == _selectedOfferingId)
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WidgetAppointmentBookingSheet(
        doctor: doc,
        slotId: slotId,
        offering: offering,
        profiles: family.profiles,
        onConfirm: (profileId) async {
          Navigator.pop(ctx);
          _processBooking(context, appointment, slotId, profileId, _selectedOfferingId);
        },
      ),
    );
  }

  Future<void> _processBooking(BuildContext context, AppointmentProvider provider, int slotId, int profileId, int? offeringId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    final success = await provider.bookSlot(slotId, profileId, offeringId: offeringId);
    if (context.mounted) Navigator.pop(context);
    if (success && context.mounted) {
      WidgetSnackbar.success(context, AppContent.get('common.success.appointmentBooked'));
      context.pop();
    } else if (context.mounted) {
      WidgetSnackbar.error(context, provider.errorMessage ?? AppContent.get('common.errors.unknown'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discovery = context.watch<DiscoveryProvider>();
    final family = context.watch<FamilyProvider>();
    final appointment = context.watch<AppointmentProvider>();
    
    final docIdx = discovery.searchResults.indexWhere((d) => d.id == widget.doctorId);

    if (!_isInitLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (docIdx == -1) {
      return Scaffold(
        appBar: AppBar(title: Text(AppContent.get('search.screen.doctorNotFound'))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.mutedForeground),
              const SizedBox(height: AppSpacing.md),
              Text(AppContent.get('search.screen.doctorNotFoundSub')),
              TextButton(onPressed: () => context.pop(), child: Text(AppContent.get('common.buttons.back'))),
            ],
          ),
        ),
      );
    }

    final doc = discovery.searchResults[docIdx];
    final openSlots = doc.openSlots.where((s) => !s.isBooked).toList();
    final dates = openSlots.map((s) {
      final start = s.startTime;
      return DateTime(start.year, start.month, start.day);
    }).toSet().toList()..sort();

    if (_selectedDate == null && dates.isNotEmpty) _selectedDate = dates.first;

    final filteredSlots = openSlots.where((s) {
      if (_selectedDate == null) return false;
      final start = s.startTime;
      return start.year == _selectedDate!.year && start.month == _selectedDate!.month && start.day == _selectedDate!.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: WidgetCircleButton(icon: Icons.arrow_back_ios_new, onTap: () => context.pop()),
            ),
            actions: [
              WidgetCircleButton(
                icon: discovery.isFavorite(widget.doctorId) ? Icons.favorite : Icons.favorite_border,
                color: discovery.isFavorite(widget.doctorId) ? AppColors.destructive : AppColors.foreground,
                onTap: () => discovery.toggleDoctorFavorite(widget.doctorId),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: WidgetSearchDoctorHeader(doc: doc),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -15),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radius3xl)),
                  boxShadow: AppShadows.md,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DoctorStatsRow(doc: doc),
                    const SizedBox(height: AppSpacing.xl),
                    WidgetSectionHeader(AppContent.get('search.doctorCard.profileOverview')),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      doc.bio ?? AppContent.get('search.doctorCard.defaultBio'),
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground, height: 1.6),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    if (doc.offerings.isNotEmpty) ...[
                      WidgetSectionHeader(AppContent.get('search.doctorCard.services')),
                      const SizedBox(height: AppSpacing.md),
                      ...doc.offerings.map((offering) {
                        final isSelected = _selectedOfferingId == offering.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            onTap: () => setState(() => _selectedOfferingId = offering.id),
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
                            title: Text(offering.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${offering.durationMinutes} min • ${offering.description ?? ""}'),
                            trailing: Text(
                              '${offering.price}€',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    WidgetSectionHeader(AppContent.get('search.doctorCard.availability')),
                    const SizedBox(height: AppSpacing.md),
                    if (dates.isEmpty)
                      _emptySlots()
                    else ...[
                      WidgetSearchDateStrip(dates: dates, selectedDate: _selectedDate, onDateSelected: (d) => setState(() => _selectedDate = d)),
                      const SizedBox(height: AppSpacing.lg),
                      SubSectionHeader(AppContent.get('search.doctorCard.availableTimes')),
                      const SizedBox(height: AppSpacing.sm),
                      WidgetAppointmentSlotGrid(
                        key: ValueKey(_selectedDate),
                        slots: filteredSlots,
                        selectedSlotId: _selectedSlotId,
                        onSlotSelected: (slotId) => setState(() => _selectedSlotId = slotId),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.huge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _bookingFAB(context, theme, discovery, family, appointment, doc, openSlots),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _emptySlots() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        AppContent.get('search.screen.noSlots'), 
        textAlign: TextAlign.center, 
        style: const TextStyle(color: AppColors.mutedForeground),
      ),
    );
  }

  Widget _bookingFAB(BuildContext context, ThemeData theme, DiscoveryProvider discovery, FamilyProvider family, AppointmentProvider appointment, DoctorModel doc, List<dynamic> openSlots) {
    int? slotToBook = _selectedSlotId;
    if (slotToBook == null && openSlots.isNotEmpty) {
      final filtered = openSlots.where((s) {
        if (_selectedDate == null) return false;
        final start = s.startTime;
        return start.year == _selectedDate!.year && start.month == _selectedDate!.month && start.day == _selectedDate!.day;
      }).toList();
      if (filtered.isNotEmpty) slotToBook = filtered.first.id;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: WidgetDoctaviaButton(
        text: AppContent.get('search.screen.bookAppointment'),
        onPressed: () {
          if (doc.offerings.isNotEmpty && _selectedOfferingId == null) {
            WidgetSnackbar.show(context, AppContent.get('search.screen.selectService'));
          } else if (slotToBook != null) {
            _showBookingSheet(context, discovery, family, appointment, doc, slotToBook);
          } else {
            WidgetSnackbar.show(context, AppContent.get('search.screen.selectSlot'));
          }
        },
      ),
    );
  }
}

