import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';
import 'package:doctavia/core/widgets/widget-confirm-dialog.dart';

class ScreenDoctorOffices extends StatefulWidget {
  const ScreenDoctorOffices({super.key});

  @override
  State<ScreenDoctorOffices> createState() => _ScreenDoctorOfficesState();
}

class _ScreenDoctorOfficesState extends State<ScreenDoctorOffices> {
  List<Map<String, dynamic>> _offices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOffices();
  }

  Future<void> _fetchOffices() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<DoctorProvider>();
      final offices = await provider.fetchOffices();
      if (mounted) setState(() => _offices = offices);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppContent.get('common.errors.generic'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addOffice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddOfficeSheet(
        onSuccess: () {
          Navigator.pop(context);
          _fetchOffices();
        },
      ),
    );
  }

  Future<void> _removeOffice(int id, String address) async {
    final confirmed = await WidgetConfirmDialog.show(
      context,
      title: AppContent.get('profile.doctor.removeOffice'),
      message: AppContent.get('profile.doctor.removeOfficeConfirm').replaceAll('{address}', address),
      confirmLabel: AppContent.get('common.buttons.remove'),
      isDestructive: true,
    );

    if (confirmed && mounted) {
      try {
        final provider = context.read<DoctorProvider>();
        await provider.removeOffice(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppContent.get('profile.doctor.removeOfficeSuccess'))),
          );
        }
        _fetchOffices();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppContent.get('profile.doctor.removeOfficeError'))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('profile.doctor.manageOffices')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offices.isEmpty
              ? _buildEmptyState(theme)
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _offices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final office = _offices[index];
                    return _OfficeCard(
                      office: office,
                      onDelete: () => _removeOffice(office['id'] as int, office['address']),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addOffice,
        icon: const Icon(Icons.add),
        label: Text(AppContent.get('profile.doctor.addOffice')),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 64, color: theme.disabledColor),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppContent.get('profile.doctor.noOffices'),
            style: TextStyle(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

class _OfficeCard extends StatelessWidget {
  final Map<String, dynamic> office;
  final VoidCallback onDelete;

  const _OfficeCard({required this.office, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    office['address'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    office['city'] ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.destructive),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOfficeSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const _AddOfficeSheet({required this.onSuccess});

  @override
  State<_AddOfficeSheet> createState() => _AddOfficeSheetState();
}

class _AddOfficeSheetState extends State<_AddOfficeSheet> {
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
        top: AppSpacing.xxl,
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppContent.get('profile.doctor.addOffice'),
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xl),
          WidgetDoctaviaInput(
            controller: _addressCtrl,
            label: AppContent.get('profile.doctor.addressLabel'),
            hint: 'e.g. 123 Medical St.',
          ),
          const SizedBox(height: AppSpacing.md),
          WidgetDoctaviaInput(
            controller: _cityCtrl,
            label: AppContent.get('profile.doctor.cityLabel'),
            hint: 'e.g. Algiers',
          ),
          const SizedBox(height: AppSpacing.xl),
          WidgetDoctaviaButton(
            text: AppContent.get('common.buttons.confirm'),
            isLoading: _isSubmitting,
            onPressed: () async {
              if (_addressCtrl.text.isEmpty || _cityCtrl.text.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              setState(() => _isSubmitting = true);
              try {
                await context.read<DoctorProvider>().addOffice(
                  address: _addressCtrl.text,
                  city: _cityCtrl.text,
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(AppContent.get('profile.doctor.addOfficeSuccess'))),
                  );
                  widget.onSuccess();
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(AppContent.get('profile.doctor.addOfficeError'))),
                  );
                }
              } finally {
                if (mounted) setState(() => _isSubmitting = false);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
