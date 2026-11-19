import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-appointment.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenAppointmentsReview extends StatefulWidget {
  final int appointmentId;
  final String doctorName;

  const ScreenAppointmentsReview({
    super.key,
    required this.appointmentId,
    required this.doctorName,
  });

  @override
  State<ScreenAppointmentsReview> createState() => _ScreenAppointmentsReviewState();
}

class _ScreenAppointmentsReviewState extends State<ScreenAppointmentsReview> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final provider = context.read<AppointmentProvider>();
      final success = await provider.submitReview(
        widget.appointmentId,
        _rating.toDouble(),
        _commentCtrl.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppContent.get('appointments.review.successMsg')), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppContent.get('appointments.review.submissionFailed'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('appointments.review.title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                AppContent.get('appointments.review.prompt').replaceAll('{name}', widget.doctorName),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            
            // Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  icon: Icon(
                    starValue <= _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = starValue),
                );
              }),
            ),
            SizedBox(height: AppSpacing.xl),
            
            WidgetDoctaviaInput(
              controller: _commentCtrl,
              label: AppContent.get('appointments.review.commentLabel'),
              hint: AppContent.get('appointments.review.commentHint'),
              maxLines: 4,
            ),
            SizedBox(height: AppSpacing.xxl),
            
            WidgetDoctaviaButton(
              text: AppContent.get('appointments.review.submitButton'),
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
