import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';

class ScreenDoctorEditProfessional extends StatefulWidget {
  const ScreenDoctorEditProfessional({super.key});

  @override
  State<ScreenDoctorEditProfessional> createState() => _ScreenDoctorEditProfessionalState();
}

class _ScreenDoctorEditProfessionalState extends State<ScreenDoctorEditProfessional> {
  final _formKey = GlobalKey<FormState>();
  final _bioCtrl = TextEditingController();
  final _categoriesCtrl = TextEditingController();
  final _servicesCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _eduCtrl = TextEditingController();
  final _equipCtrl = TextEditingController();
  final _langCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctor = context.read<DoctorProvider>();
      // Since doctor.analytics might contain the professional profile data in this simplified app
      // or we can assume it's part of the user metadata. 
      // For now, we'll try to load from a hypothetical professionalInfo map.
      final info = doctor.analytics?['professionalInfo'] as Map<String, dynamic>?;
      if (info != null) {
        _bioCtrl.text = info['bio'] ?? '';
        _categoriesCtrl.text = (info['categories'] as List?)?.join(', ') ?? '';
        _servicesCtrl.text = (info['services'] as List?)?.join(', ') ?? '';
        _expCtrl.text = (info['experienceYears'] ?? '').toString();
        _eduCtrl.text = info['education'] ?? '';
        _equipCtrl.text = (info['equipment'] as List?)?.join(', ') ?? '';
        _langCtrl.text = (info['languages'] as List?)?.join(', ') ?? '';
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'bio': _bioCtrl.text.trim(),
      'categories': _categoriesCtrl.text.split(',').where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList(),
      'services': _servicesCtrl.text.split(',').where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList(),
      'experienceYears': int.tryParse(_expCtrl.text) ?? 0,
      'education': _eduCtrl.text.trim(),
      'equipment': _equipCtrl.text.split(',').where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList(),
      'languages': _langCtrl.text.split(',').where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList(),
    };

    final provider = context.read<DoctorProvider>();
    final success = await provider.updateDoctorProfile(data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppContent.get('profile.screen.profileUpdated')), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DoctorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('profile.doctor.editProfessional')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WidgetDoctaviaInput(
                controller: _bioCtrl,
                label: AppContent.get('profile.doctor.bioLabel'),
                hint: AppContent.get('profile.doctor.bioHint'),
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              WidgetDoctaviaInput(
                controller: _categoriesCtrl,
                label: AppContent.get('profile.doctor.specialtiesLabel'),
                hint: AppContent.get('profile.doctor.specialtiesHint'),
              ),
              const SizedBox(height: AppSpacing.md),
              WidgetDoctaviaInput(
                controller: _servicesCtrl,
                label: AppContent.get('profile.doctor.servicesLabel'),
                hint: AppContent.get('profile.doctor.servicesHint'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: WidgetDoctaviaInput(
                      controller: _expCtrl,
                      label: AppContent.get('profile.doctor.experienceLabel'),
                      hint: AppContent.get('profile.doctor.experienceHint'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              WidgetDoctaviaInput(
                controller: _eduCtrl,
                label: AppContent.get('profile.doctor.educationLabel'),
                hint: AppContent.get('profile.doctor.educationHint'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              WidgetDoctaviaInput(
                controller: _equipCtrl,
                label: AppContent.get('profile.doctor.equipmentLabel'),
                hint: AppContent.get('profile.doctor.equipmentHint'),
              ),
              const SizedBox(height: AppSpacing.md),
              WidgetDoctaviaInput(
                controller: _langCtrl,
                label: AppContent.get('profile.doctor.languagesLabel'),
                hint: AppContent.get('profile.doctor.languagesHint'),
              ),
              const SizedBox(height: AppSpacing.xl),
              WidgetDoctaviaButton(
                text: AppContent.get('common.buttons.save'),
                isLoading: provider.isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
