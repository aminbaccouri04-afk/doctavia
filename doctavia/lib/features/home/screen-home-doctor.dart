import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/widgets/widget-user-avatar.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/widgets/widget-shimmer-loaders.dart';
import './widgets/widget-home-active-session.dart';
import './widgets/widget-home-dashboard-action.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenHomeDoctor extends StatefulWidget {
  const ScreenHomeDoctor({super.key});

  @override
  State<ScreenHomeDoctor> createState() => _ScreenHomeDoctorState();
}

class _ScreenHomeDoctorState extends State<ScreenHomeDoctor> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().fetchDashboard();
      context.read<DoctorProvider>().fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;
    final provider = context.watch<DoctorProvider>();

    return WidgetScaffold(
      title: AppContent.get('home.doctor.title'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ),
      ],
      body: provider.isLoading
          ? const ShimmerList(itemCount: 4, child: WidgetShimmerDoctorCard())
          : ListView(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              children: [
                const SizedBox(height: AppSpacing.md),
                _buildPremiumHeader(user, provider),
                const SizedBox(height: AppSpacing.lg),

                // ─── Active Session Alert ─────────────────────────────
                if (provider.activeConsultation != null) ...[
                  WidgetHomeActiveSession(
                    appointment: provider.activeConsultation,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // ─── Analytics KPIs ──────────────────────────────────
                if (provider.analytics != null) ...[
                  _buildAnalyticsSection(theme, provider.analytics!),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // ─── Direct Actions ──────────────────────────────────
                Text(
                  AppContent.get('home.doctor.quickActions'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.88,
                  children: [
                    WidgetHomeDashboardAction(
                      title: AppContent.get('home.doctor.appointments'),
                      subtitle: AppContent.get(
                        'home.doctor.appointmentsSubtitle',
                      ),
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.primary,
                      onTap: () => context.push('/schedule'),
                    ),
                    WidgetHomeDashboardAction(
                      title: AppContent.get('home.doctor.patients'),
                      subtitle: AppContent.get('home.doctor.patientsSubtitle'),
                      icon: Icons.people_alt_rounded,
                      color: Colors.indigo,
                      onTap: () => context.push('/patients'),
                    ),
                    WidgetHomeDashboardAction(
                      title: AppContent.get('home.doctor.staff'),
                      subtitle: AppContent.get('home.doctor.staffSubtitle'),
                      icon: Icons.key_rounded,
                      color: AppColors.warning,
                      onTap: () => _showStaffCode(provider),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
    );
  }

  Widget _buildPremiumHeader(dynamic user, DoctorProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppContent.get('home.doctor.greeting'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dr. ${user?.email.split('@')[0] ?? AppContent.get('home.doctor.defaultPhysician')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _pickAndUploadAvatar(provider),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: WidgetUserAvatar(
                avatarUrl: provider.myProfile?.avatarUrl,
                radius: 32,
                fallbackIcon: Icons.medical_services,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(DoctorProvider provider) async {
    // Explicitly request permissions for better stability on Android
    PermissionStatus status;
    if (Theme.of(context).platform == TargetPlatform.android) {
      status = await Permission.photos.request();
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppContent.get('home.doctor.galleryPermission')),
            action: SnackBarAction(
              label: AppContent.get('common.buttons.settings'),
              onPressed: openAppSettings,
            ),
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
        : (extension == 'png'
              ? MediaType('image', 'png')
              : MediaType('image', 'jpeg'));

    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      image.path,
      filename: image.name,
      contentType: contentType,
    );

    final success = await provider.uploadProfilePicture(multipartFile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? AppContent.get('home.doctor.profileUpdateSuccess')
                : provider.errorMessage ??
                      AppContent.get('home.doctor.profileUpdateFailed'),
          ),
          backgroundColor: success ? AppColors.success : AppColors.destructive,
        ),
      );
    }
  }

  void _showStaffCode(DoctorProvider provider) async {
    final code = await provider.fetchStaffCode();
    if (!mounted) return;

    if (code != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppContent.get('home.doctor.authCodeTitle')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppContent.get('home.doctor.authCodeSubtitle')),
              const SizedBox(height: AppSpacing.md),
              SelectableText(
                code,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppContent.get('common.buttons.close')),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAnalyticsSection(ThemeData theme, Map<String, dynamic> data) {
    final kpis = data['kpis'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUSINESS INSIGHTS',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                'Fulfillment',
                '${(kpis['fulfillmentRate'] ?? 0).toStringAsFixed(1)}%',
                Icons.trending_up_rounded,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildKpiCard(
                'Monthly Vol',
                '${kpis['thirtyDayVolume'] ?? 0}',
                Icons.bar_chart_rounded,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildKpiCard(
                'Avg Rating',
                '${(kpis['avgRating'] ?? 5.0).toStringAsFixed(1)}',
                Icons.star_rounded,
                Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
