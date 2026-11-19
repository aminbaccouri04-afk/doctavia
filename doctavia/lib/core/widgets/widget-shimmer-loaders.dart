import 'package:flutter/material.dart';
import 'package:doctavia/core/theme/theme.dart';

/// A standard premium loader for the entire application.
class WidgetDoctaviaLoader extends StatelessWidget {
  final double size;
  const WidgetDoctaviaLoader({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}

class WidgetShimmerAppointment extends StatelessWidget {
  const WidgetShimmerAppointment({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.xl),
    child: WidgetDoctaviaLoader(),
  );
}

class AppointmentBannerShimmer extends StatelessWidget {
  const AppointmentBannerShimmer({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 180,
    child: WidgetDoctaviaLoader(size: 40),
  );
}

class WidgetShimmerDoctorCard extends StatelessWidget {
  const WidgetShimmerDoctorCard({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.lg),
    child: WidgetDoctaviaLoader(),
  );
}

class RecordCardShimmer extends StatelessWidget {
  const RecordCardShimmer({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: WidgetDoctaviaLoader(),
  );
}

class SpecialtyPillShimmer extends StatelessWidget {
  const SpecialtyPillShimmer({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: WidgetDoctaviaLoader(size: 20),
  );
}

class RegistryRowShimmer extends StatelessWidget {
  const RegistryRowShimmer({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.lg),
    child: WidgetDoctaviaLoader(),
  );
}

class MetricGridShimmer extends StatelessWidget {
  const MetricGridShimmer({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 200,
    child: WidgetDoctaviaLoader(size: 40),
  );
}

class ChartShimmer extends StatelessWidget {
  const ChartShimmer({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 280,
    child: WidgetDoctaviaLoader(size: 40),
  );
}

class ShimmerList extends StatelessWidget {
  final Widget child;
  final int itemCount;

  const ShimmerList({super.key, required this.child, this.itemCount = 1});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: WidgetDoctaviaLoader(size: 32),
    );
  }
}
