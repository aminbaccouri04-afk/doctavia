import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:doctavia/core/providers/provider-clinical.dart';
import 'package:doctavia/core/models/model-medical-record.dart';
import 'package:doctavia/core/widgets/widget-confirm-dialog.dart';
import 'package:doctavia/core/widgets/widget-snackbar.dart';
import 'package:doctavia/features/vault/widgets/widget-vault-record-card.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';
import 'package:doctavia/core/widgets/widget-empty-state.dart';
import 'package:doctavia/core/providers/provider-content.dart';

/// The "Records" tab content for the Medical Vault screen.
class WidgetVaultRecordsTab extends StatelessWidget {
  final ClinicalProvider provider;
  final int? selectedProfileId;

  const WidgetVaultRecordsTab({
    super.key,
    required this.provider,
    required this.selectedProfileId,
  });

  Future<void> _uploadFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        final ext = platformFile.name.split('.').last.toLowerCase();
        final contentType = ext == 'jpg' || ext == 'jpeg'
            ? MediaType('image', 'jpeg')
            : ext == 'png'
                ? MediaType('image', 'png')
                : ext == 'pdf'
                    ? MediaType('application', 'pdf')
                    : MediaType('application', 'octet-stream');

        http.MultipartFile? file;
        if (platformFile.bytes != null) {
          file = http.MultipartFile.fromBytes('document', platformFile.bytes!, filename: platformFile.name, contentType: contentType);
        } else if (platformFile.path != null) {
          file = await http.MultipartFile.fromPath('document', platformFile.path!, contentType: contentType);
        }

        if (file != null && selectedProfileId != null) {
          final success = await provider.uploadRecord(selectedProfileId!, file);
          if (context.mounted && success) WidgetSnackbar.success(context, AppContent.get('vault.screen.uploadSuccess'));
        }
      }
    } catch (e) {
      if (context.mounted) WidgetSnackbar.error(context, '${AppContent.get('common.errors.uploadingFile')}$e');
    }
  }

  Future<void> _viewRecord(BuildContext context, MedicalRecord record) async {
    final baseUrl = provider.apiClient.baseUrl.replaceAll('/api/v1', '');
    final url = Uri.parse('$baseUrl${record.fileUrl}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw AppContent.get('common.errors.launchUrl').replaceAll('{url}', url.toString());
      }
    } catch (e) {
      if (context.mounted) WidgetSnackbar.error(context, '${AppContent.get('common.errors.openingFile')}$e');
    }
  }

  Future<void> _confirmDeletion(BuildContext context, MedicalRecord record) async {
    final confirmed = await WidgetConfirmDialog.show(
      context,
      title: AppContent.get('vault.screen.deleteConfirmTitle'),
      message: AppContent.get('vault.screen.deleteConfirmMsg').replaceAll('{name}', record.fileName),
      confirmLabel: AppContent.get('common.buttons.delete'),
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final success = await provider.deleteRecord(record.id);
    if (context.mounted && success) WidgetSnackbar.success(context, AppContent.get('vault.screen.deleteSuccess'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton.icon(
            onPressed: provider.isLoading ? null : () => _uploadFile(context),
            icon: const Icon(Icons.cloud_upload),
            label: Text(AppContent.get('vault.screen.uploadNew')),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          ),
        ),
        Expanded(
          child: provider.isLoading && provider.medicalRecords.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: ShimmerList(itemCount: 5, child: RecordCardShimmer()),
                )
              : provider.medicalRecords.isEmpty
                  ? WidgetEmptyState(
                      icon: Icons.folder_open,
                      title: AppContent.get('vault.screen.noRecords'),
                      subtitle: AppContent.get('vault.screen.noRecordsSub'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: provider.medicalRecords.length,
                      itemBuilder: (context, index) {
                        final record = provider.medicalRecords[index];
                        return WidgetVaultRecordCard(
                          record: record,
                          onTap: () => _viewRecord(context, record),
                          onDelete: () => _confirmDeletion(context, record),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
