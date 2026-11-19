import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doctavia/core/models/model-availability-slot.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetAppointmentSlotGrid extends StatelessWidget {
  final List<AvailabilitySlot> slots;
  final int? selectedSlotId;
  final Function(int slotId) onSlotSelected;

  const WidgetAppointmentSlotGrid({
    super.key,
    required this.slots,
    this.selectedSlotId,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          'No slots available today.',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: slots.length,
      itemBuilder: (ctx, i) {
        final slot = slots[i];
        final isSelected = slot.id == selectedSlotId;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).primaryColor
                : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.black,
            elevation: isSelected ? 4 : 0,
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : AppColors.muted,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => onSlotSelected(slot.id),
          child: Text(
            DateFormat.jm().format(slot.startTime),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      },
    );
  }
}
