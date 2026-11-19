import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/widgets/widget-user-avatar.dart';
import 'package:doctavia/core/widgets/widget-confirm-dialog.dart';
import 'package:doctavia/core/theme/theme.dart';
import './widgets/widget-profile-action.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenProfileDoctor extends StatefulWidget {
  const ScreenProfileDoctor({super.key});

  @override
  State<ScreenProfileDoctor> createState() => _ScreenProfileDoctorState();
}

class _ScreenProfileDoctorState extends State<ScreenProfileDoctor> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DoctorProvider>();
      if (provider.myProfile == null) {
        provider.fetchDashboard();
      }
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isDenied) status = await Permission.storage.request();

    if (status.isPermanentlyDenied) {
      if (mounted) {
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

    final ext = image.path.split('.').last.toLowerCase();
    final contentType = (ext == 'png') ? MediaType('image', 'png') : MediaType('image', 'jpeg');
    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      image.path,
      filename: image.name,
      contentType: contentType,
    );

    if (!mounted) return;
    final provider = context.read<DoctorProvider>();
    final success = await provider.uploadProfilePicture(multipartFile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? AppContent.get('home.doctor.profileUpdateSuccess') : provider.errorMessage ?? AppContent.get('home.doctor.profileUpdateFailed')),
          backgroundColor: success ? AppColors.success : AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final doctor = context.watch<DoctorProvider>();
    final profile = doctor.myProfile;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Hero Header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            toolbarHeight: 64,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => context.push('/settings'),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _DoctorProfileHeader(
                avatarUrl: profile?.avatarUrl,
                name: profile?.fullName ?? auth.currentUser?.email.split('@')[0] ?? AppContent.get('common.labels.doctorRole'),
                subtitle: AppContent.get('profile.doctor.professional'),
                onAvatarTap: _pickAndUploadAvatar,
              ),
            ),
          ),

          // ─── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  _DoctorQuickStats(
                    appointments: doctor.appointments.length,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Practice Actions
                  Text(
                    AppContent.get('profile.doctor.practice'),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  WidgetProfileAction(
                    icon: Icons.calendar_month_outlined,
                    title: AppContent.get('profile.doctor.manageSchedule'),
                    subtitle: AppContent.get('profile.doctor.manageScheduleSub'),
                    onTap: () => context.push('/schedule'),
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.people_alt_outlined,
                    title: AppContent.get('profile.doctor.patientRegistry'),
                    subtitle: AppContent.get('profile.doctor.patientRegistrySub'),
                    onTap: () => context.push('/patients'),
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.badge_outlined,
                    title: AppContent.get('settings.staff.title'),
                    subtitle: AppContent.get('settings.screen.secretaryCodeSub'),
                    onTap: () => context.push('/settings/staff'),
                    color: Colors.orange,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Professional Profile
                  Text(
                    AppContent.get('profile.patient.profiles'),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  WidgetProfileAction(
                    icon: Icons.edit_outlined,
                    title: AppContent.get('profile.doctor.editProfessional'),
                    subtitle: AppContent.get('profile.doctor.editProfessionalSub'),
                    onTap: () => context.push('/doctor/profile/edit-professional'),
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  WidgetProfileAction(
                    icon: Icons.business_outlined,
                    title: AppContent.get('profile.doctor.manageOffices'),
                    subtitle: AppContent.get('profile.doctor.manageOfficesSub'),
                    onTap: () => context.push('/doctor/profile/offices'),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  WidgetProfileAction(
                    icon: Icons.logout,
                    title: AppContent.get('profile.screen.signOut'),
                    subtitle: AppContent.get('profile.screen.signOutMessageDoctor'),
                    onTap: () async {
                      final confirmed = await WidgetConfirmDialog.show(
                        context,
                        title: AppContent.get('profile.screen.signOutConfirm'),
                        message: AppContent.get('profile.screen.signOutMessageDoctor'),
                        confirmLabel: AppContent.get('profile.screen.signOut'),
                        isDestructive: true,
                      );
                      if (confirmed && context.mounted) {
                        await auth.logout();
                      }
                    },
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private Widgets ────────────────────────────────────────────────────────

class _DoctorProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String subtitle;
  final VoidCallback onAvatarTap;

  const _DoctorProfileHeader({
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.onAvatarTap,
  });

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
                    onTap: onAvatarTap,
                    child: Stack(
                      children: [
                        WidgetUserAvatar(
                          avatarUrl: avatarUrl,
                          radius: 40,
                          fallbackIcon: Icons.medical_services_outlined,
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
                            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
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
                          '${AppContent.get('common.labels.doctorPrefix')} $name',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
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

class _DoctorQuickStats extends StatelessWidget {
  final int appointments;

  const _DoctorQuickStats({
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: _StatItem(value: appointments.toString(), label: AppContent.get('profile.doctor.appointments')),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

