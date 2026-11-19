import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class WidgetScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBarBottom;
  final Color? appBarColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool hasHorizontalPadding;

  const WidgetScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.appBarBottom,
    this.appBarColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.hasHorizontalPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: title != null || appBarBottom != null
          ? AppBar(
              backgroundColor: appBarColor,
              toolbarHeight: 64,
              title: title != null 
                ? Text(title!, style: const TextStyle(fontWeight: FontWeight.bold))
                : null,
              actions: actions,
              bottom: appBarBottom,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        top: !extendBodyBehindAppBar,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: hasHorizontalPadding ? AppSpacing.xl : 0,
          ),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar != null
          ? _buildGlassBottomNav(bottomNavigationBar!)
          : null,
    );
  }

  Widget _buildGlassBottomNav(Widget nav) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: const Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: nav,
        ),
      ),
    );
  }
}
