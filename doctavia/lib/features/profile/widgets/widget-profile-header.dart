import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/widgets/widget-user-avatar.dart';
import 'package:doctavia/core/models/model-patient-profile.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/theme/theme.dart';

class WidgetProfileHeader extends StatelessWidget {
  final PatientProfile profile;

  const WidgetProfileHeader({super.key, required this.profile});

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    // Explicitly request permissions for better stability on Android (Oppo/Realme/etc)
    PermissionStatus status;
    if (Theme.of(context).platform == TargetPlatform.android) {
      // For Android 13+, we need photos permission. For older, storage.
      // permission_handler's .photos handles this abstraction well.
      status = await Permission.photos.request();
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppContent.get('home.doctor.galleryPermission')),
            action: SnackBarAction(label: AppContent.get('common.buttons.settings'), onPressed: openAppSettings),
          ),
        );
      }
      return;
    }

    if (!status.isGranted && !status.isLimited) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    final String extension = image.path.split('.').last.toLowerCase();
    final MediaType contentType = (extension == 'jpg' || extension == 'jpeg')
        ? MediaType('image', 'jpeg')
        : (extension == 'png' ? MediaType('image', 'png') : MediaType('image', 'jpeg'));

    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      image.path,
      filename: image.name,
      contentType: contentType,
    );

    if (!context.mounted) return;
    final provider = context.read<FamilyProvider>();
    final success = await provider.uploadAvatar(profile.id, multipartFile);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? AppContent.get('profile.screen.profileUpdated') : provider.errorMessage ?? AppContent.get('home.doctor.profileUpdateFailed')),
          backgroundColor: success ? AppColors.success : AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickAndUploadAvatar(context),
                    child: Stack(
                      children: [
                        WidgetUserAvatar(
                          avatarUrl: profile.avatarUrl,
                          radius: 40,
                          fallbackIcon: Icons.person,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          iconColor: Colors.white,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppContent.get('profile.patient.account'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
