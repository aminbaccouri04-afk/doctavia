import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-appointment.dart'; // This is now AppointmentProvider
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';

class WidgetAppointmentReviewDialog extends StatefulWidget {
  final int appointmentId;
  final String doctorName;

  const WidgetAppointmentReviewDialog({
    super.key,
    required this.appointmentId,
    required this.doctorName,
  });

  @override
  State<WidgetAppointmentReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<WidgetAppointmentReviewDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();

  Future<void> _submit() async {
    final provider = context.read<AppointmentProvider>();
    final success = await provider.submitReview(
      widget.appointmentId,
      _rating,
      _commentController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppContent.get('appointments.review.successMsg')),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                AppContent.get('appointments.review.submissionFailed'),
          ),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      title: Text(
        AppContent.get(
          'appointments.review.rateTitle',
        ).replaceAll('{name}', widget.doctorName),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppContent.get(
              'appointments.review.prompt',
            ).replaceAll('{name}', widget.doctorName),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return InkWell(
                onTap: () => setState(() => _rating = index + 1.0),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          WidgetDoctaviaInput(
            controller: _commentController,
            maxLines: 3,
            label: '',
            hint: AppContent.get('appointments.review.commentHint'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppContent.get('common.buttons.cancel')),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: WidgetDoctaviaButton(
            text: AppContent.get('common.buttons.submit'),
            isLoading: provider.isLoading,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}
