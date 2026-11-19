import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';
import 'package:doctavia/core/widgets/widget-selectable-card.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenAuthSignup extends StatefulWidget {
  const ScreenAuthSignup({super.key});

  @override
  State<ScreenAuthSignup> createState() => _ScreenAuthSignupState();
}

class _ScreenAuthSignupState extends State<ScreenAuthSignup> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _authCodeCtrl = TextEditingController();
  String _selectedRole = 'patient';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    _dobCtrl.dispose();
    _authCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.signup(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _selectedRole,
      fullName: _fullNameCtrl.text.trim(),
      dateOfBirth: _dobCtrl.text.trim(),
      authCode:
          _selectedRole == 'secretary' ? _authCodeCtrl.text.trim() : null,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   const SizedBox(height: AppSpacing.xxl),
                  // ─── Header ────────────────────────────────
                  Text(
                    AppContent.get('auth.signup.title'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppContent.get('auth.signup.subtitle'),
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

                  // ─── Role Selector ─────────────────────────
                  Text(
                    AppContent.get('auth.signup.roleLabel'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: WidgetSelectableCard(
                          label: AppContent.get('auth.signup.patient'),
                          icon: Icons.person_outline,
                          isSelected: _selectedRole == 'patient',
                          onTap: () => setState(() => _selectedRole = 'patient'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: WidgetSelectableCard(
                          label: AppContent.get('auth.signup.doctor'),
                          icon: Icons.medical_services_outlined,
                          isSelected: _selectedRole == 'doctor',
                          onTap: () => setState(() => _selectedRole = 'doctor'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: WidgetSelectableCard(
                          label: AppContent.get('auth.signup.secretary'),
                          icon: Icons.badge_outlined,
                          isSelected: _selectedRole == 'secretary',
                          onTap: () => setState(() => _selectedRole = 'secretary'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ─── Full Name ─────────────────────────────
                  WidgetDoctaviaInput(
                    controller: _fullNameCtrl,
                    label: AppContent.get('auth.signup.nameLabel'),
                    hint: AppContent.get('auth.signup.nameHint'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? AppContent.get('auth.signup.nameRequired') : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
 
                  // ─── Email ─────────────────────────────────
                  WidgetDoctaviaInput(
                    controller: _emailCtrl,
                    label: AppContent.get('auth.signup.emailLabel'),
                    hint: AppContent.get('auth.signup.emailHint'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppContent.get('auth.signup.emailRequired');
                      if (!v.contains('@')) return AppContent.get('auth.signup.emailInvalid');
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
 
                  // ─── Password ──────────────────────────────
                  WidgetDoctaviaInput(
                    controller: _passwordCtrl,
                    label: AppContent.get('auth.signup.passwordLabel'),
                    hint: AppContent.get('auth.signup.passwordHint'),
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppContent.get('auth.signup.passwordRequired');
                      }
                      if (v.length < 6) {
                        return AppContent.get('auth.signup.passwordMinLength');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
 
                  // ─── Date of Birth ─────────────────────────
                  WidgetDoctaviaInput(
                    controller: _dobCtrl,
                    label: AppContent.get('auth.signup.dobLabel'),
                    hint: AppContent.get('auth.signup.dobHint'),
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? AppContent.get('auth.signup.required') : null,
                    suffixIcon: const Icon(Icons.calendar_month_outlined,
                          size: 20,
                          color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: AppSpacing.md),
 
                  // ─── Secretary Auth Code (Conditional) ─────
                  if (_selectedRole == 'secretary') ...[
                    WidgetDoctaviaInput(
                      controller: _authCodeCtrl,
                      label: AppContent.get('auth.signup.authCodeLabel'),
                      hint: AppContent.get('auth.signup.authCodeHint'),
                      validator: (v) => (v == null || v.isEmpty)
                          ? AppContent.get('auth.signup.authCodeRequired')
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // ─── Submit ────────────────────────────────
                  WidgetDoctaviaButton(
                    text: AppContent.get('auth.signup.submit'),
                    isLoading: auth.isLoading,
                    onPressed: _handleSignup,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ─── Login Link ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppContent.get('auth.signup.haveAccount'),
                        style: const TextStyle(color: AppColors.mutedForeground),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          AppContent.get('auth.signup.signIn'),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ─── Role Selection Chip ──────────────────────────────────────────
// Moved to shared WidgetSelectableCard widget
