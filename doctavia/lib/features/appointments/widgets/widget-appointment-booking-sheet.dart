import 'package:flutter/material.dart';
import 'package:doctavia/core/models/model-doctor.dart';
import 'package:doctavia/core/models/model-patient-profile.dart';
import 'package:doctavia/core/models/model-offering.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-dropdown.dart';

class WidgetAppointmentBookingSheet extends StatefulWidget {
  final DoctorModel doctor;
  final int slotId;
  final Offering? offering;
  final List<PatientProfile> profiles;
  final Function(int profileId) onConfirm;

  const WidgetAppointmentBookingSheet({
    super.key,
    required this.doctor,
    required this.slotId,
    this.offering,
    required this.profiles,
    required this.onConfirm,
  });

  @override
  State<WidgetAppointmentBookingSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<WidgetAppointmentBookingSheet> {
  int? _selectedProfileId;

  @override
  void initState() {
    super.initState();
    if (widget.profiles.isNotEmpty) {
      _selectedProfileId = widget.profiles.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius4xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                Text(
                  widget.offering != null 
                    ? widget.offering!.name
                    : AppContent.get('appointments.booking.title'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.offering != null) ...[
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.offering!.durationMinutes} mins',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.euro, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.offering!.price}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  AppContent.get('appointments.booking.subtitle').replaceAll('{name}', widget.doctor.fullName),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SizedBox(height: AppSpacing.xl),
              
              WidgetDoctaviaDropdown<int>(
                label: AppContent.get('appointments.booking.profileLabel'),
                value: _selectedProfileId,
                items: widget.profiles.map((p) {
                  return DropdownMenuItem<int>(
                    value: p.id,
                    child: Text('${p.fullName} (${AppContent.translateRelationship(p.relationship)})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedProfileId = val),
              ),

              const SizedBox(height: AppSpacing.xl),
  
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _selectedProfileId == null
                      ? null
                      : () => widget.onConfirm(_selectedProfileId!),
                  child: Text(AppContent.get('appointments.booking.confirm')),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
