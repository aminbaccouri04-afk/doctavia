import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/models/model-appointment.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';
import './widgets/widget-consultation-soap-tab.dart';
import './widgets/widget-consultation-vitals-tab.dart';
import './widgets/widget-consultation-prescriptions-tab.dart';

class ScreenAppointmentsConsultation extends StatefulWidget {
  final Appointment appointment;

  const ScreenAppointmentsConsultation({super.key, required this.appointment});

  @override
  State<ScreenAppointmentsConsultation> createState() =>
      _ScreenAppointmentsConsultationState();
}

class _ScreenAppointmentsConsultationState
    extends State<ScreenAppointmentsConsultation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // SOAP Controllers
  final _subjectiveCtrl = TextEditingController();
  final _objectiveCtrl = TextEditingController();
  final _assessmentCtrl = TextEditingController();
  final _planCtrl = TextEditingController();
  final _internalCtrl = TextEditingController();

  // Vitals Controllers
  final _bpCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  // Prescriptions Data
  final List<Map<String, String>> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectiveCtrl.dispose();
    _objectiveCtrl.dispose();
    _assessmentCtrl.dispose();
    _planCtrl.dispose();
    _internalCtrl.dispose();
    _bpCtrl.dispose();
    _hrCtrl.dispose();
    _tempCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'subjective': _subjectiveCtrl.text,
      'objective': _objectiveCtrl.text,
      'assessment': _assessmentCtrl.text,
      'plan': _planCtrl.text,
      'internalNotes': _internalCtrl.text,
      'vitals': {
        'bp': _bpCtrl.text,
        'hr': _hrCtrl.text,
        'temp': _tempCtrl.text,
        'weight': _weightCtrl.text,
      },
      'prescriptions': _prescriptions,
    };

    final provider = context.read<DoctorProvider>();
    final success = await provider.finishConsultation(
      widget.appointment.id,
      data,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppContent.get('appointments.consultation.success')),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DoctorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppContent.get('appointments.consultation.title')),
            Text(
              '${AppContent.get('appointments.consultation.patientLabel')}${widget.appointment.patientName}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppContent.get('appointments.consultation.soapNotes')),
            Tab(text: AppContent.get('appointments.consultation.vitals')),
            Tab(
              text: AppContent.get('appointments.consultation.prescriptions'),
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  WidgetConsultationSoapTab(
                    subjectiveCtrl: _subjectiveCtrl,
                    objectiveCtrl: _objectiveCtrl,
                    assessmentCtrl: _assessmentCtrl,
                    planCtrl: _planCtrl,
                    internalCtrl: _internalCtrl,
                  ),
                  WidgetConsultationVitalsTab(
                    bpCtrl: _bpCtrl,
                    hrCtrl: _hrCtrl,
                    tempCtrl: _tempCtrl,
                    weightCtrl: _weightCtrl,
                    onVitalsChanged: () => setState(() {}),
                  ),
                  WidgetConsultationPrescriptionsTab(
                    prescriptions: _prescriptions,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: WidgetDoctaviaButton(
          text: AppContent.get('appointments.consultation.complete'),
          isLoading: provider.isLoading,
          onPressed: _save,
        ),
      ),
    );
  }
}
