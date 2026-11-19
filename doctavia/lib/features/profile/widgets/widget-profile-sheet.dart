import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/models/model-patient-profile.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-dropdown.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';

class WidgetProfileSheet extends StatefulWidget {
  final PatientProfile? profile;
  const WidgetProfileSheet({super.key, this.profile});

  @override
  State<WidgetProfileSheet> createState() => _ProfileManagementSheetState();
}

class _ProfileManagementSheetState extends State<WidgetProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _dobCtrl;
  late String _relationship;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile?.fullName);
    _dobCtrl = TextEditingController(text: widget.profile?.dateOfBirth);
    _relationship = widget.profile?.relationship ?? 'Child';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final provider = context.read<FamilyProvider>();
    bool success;
    
    try {
      if (widget.profile != null) {
        success = await provider.updateProfile(
          widget.profile!.id,
          _nameCtrl.text.trim(),
          _relationship,
          _dobCtrl.text.trim(),
        );
      } else {
        success = await provider.addProfile(
          _nameCtrl.text.trim(),
          _relationship,
          _dobCtrl.text.trim(),
        );
      }
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.profile != null ? AppContent.get('profile.sheet.updateSuccess') : AppContent.get('profile.sheet.addSuccess')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Text(
              widget.profile != null ? AppContent.get('profile.family.editMember') : AppContent.get('profile.family.addMember'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  WidgetDoctaviaInput(
                    controller: _nameCtrl,
                    label: AppContent.get('profile.sheet.fullName'),
                    validator: (v) => v!.isEmpty ? AppContent.get('profile.sheet.required') : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  WidgetDoctaviaInput(
                    controller: _dobCtrl,
                    label: AppContent.get('profile.sheet.dateOfBirth'),
                    hint: AppContent.get('profile.sheet.dateOfBirthHint'),
                    validator: (v) => v!.isEmpty ? AppContent.get('profile.sheet.required') : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  WidgetDoctaviaDropdown<String>(
                    label: AppContent.get('profile.sheet.relationship'),
                    value: _relationship,
                    items: ['Self', 'Spouse', 'Child', 'Parent', 'Other'].map((r) => 
                      DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setState(() => _relationship = val!),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            WidgetDoctaviaButton(
              text: widget.profile != null ? AppContent.get('profile.sheet.updateProfile') : AppContent.get('profile.sheet.addProfile'),
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppContent.get('common.buttons.cancel'),
                  style: const TextStyle(color: AppColors.mutedForeground),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
