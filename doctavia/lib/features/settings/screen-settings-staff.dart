import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:doctavia/core/widgets/widget-confirm-dialog.dart';
import 'package:doctavia/core/theme/theme.dart';

class ScreenSettingsStaff extends StatefulWidget {
  const ScreenSettingsStaff({super.key});

  @override
  State<ScreenSettingsStaff> createState() => _ScreenSettingsStaffState();
}

class _ScreenSettingsStaffState extends State<ScreenSettingsStaff> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().fetchStaffMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctor = context.watch<DoctorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('staff.title')),
      ),
      body: doctor.isLoading && doctor.staffMembers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: doctor.fetchStaffMembers,
              child: doctor.staffMembers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: doctor.staffMembers.length,
                      itemBuilder: (context, index) {
                        final member = doctor.staffMembers[index];
                        final linkedAt = DateTime.parse(member['linkedAt']);
                        final dateStr = DateFormat('dd/MM/yyyy').format(linkedAt);

                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.secondary,
                              child: const Icon(Icons.badge_outlined, color: AppColors.primary),
                            ),
                            title: Text(
                              member['fullName'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              AppContent.get('staff.linkedAt').replaceAll('{date}', dateStr),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_remove_outlined, color: AppColors.destructive),
                              onPressed: () => _removeMember(member),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.mutedForeground.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppContent.get('staff.noStaff'),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeMember(Map<String, dynamic> member) async {
    final confirmed = await WidgetConfirmDialog.show(
      context,
      title: AppContent.get('staff.removeConfirmTitle'),
      message: AppContent.get('staff.removeConfirmMessage'),
      confirmLabel: AppContent.get('common.buttons.confirm'),
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final success = await context.read<DoctorProvider>().removeStaffMember(member['id']);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppContent.get('staff.removeSuccess'))),
        );
      }
    }
  }
}
