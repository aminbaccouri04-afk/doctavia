import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenAuthLogin extends StatefulWidget {
  const ScreenAuthLogin({super.key});

  @override
  State<ScreenAuthLogin> createState() => _ScreenAuthLoginState();
}

class _ScreenAuthLoginState extends State<ScreenAuthLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (auth.isAuthenticated) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Logo & Header ──────────────────────────
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    AppContent.get('auth.login.title'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppContent.get('auth.login.subtitle'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // ─── Error Banner ──────────────────────────
                  if (auth.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.destructive, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 20, color: AppColors.destructive),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.destructive,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // ─── Email ─────────────────────────────────
                  WidgetDoctaviaInput(
                    controller: _emailCtrl,
                    label: AppContent.get('auth.login.emailLabel'),
                    hint: AppContent.get('auth.login.emailHint'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppContent.get('auth.login.emailRequired');
                      if (!v.contains('@')) return AppContent.get('auth.login.emailInvalid');
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
 
                  // ─── Password ──────────────────────────────
                  WidgetDoctaviaInput(
                    controller: _passwordCtrl,
                    label: AppContent.get('auth.login.passwordLabel'),
                    hint: AppContent.get('auth.login.passwordHint'),
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppContent.get('auth.login.passwordRequired');
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ─── Submit ────────────────────────────────
                  WidgetDoctaviaButton(
                    text: AppContent.get('auth.login.submit'),
                    isLoading: auth.isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ─── Sign Up Link ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppContent.get('auth.login.noAccount'),
                        style: const TextStyle(color: AppColors.mutedForeground),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: Text(
                          AppContent.get('auth.login.signUp'),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
