import 'package:flutter/material.dart';
import '../theme/theme.dart';

class WidgetDoctaviaDropdown<T> extends StatefulWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final String? hint;

  const WidgetDoctaviaDropdown({
    super.key,
    this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.hint,
  });

  @override
  State<WidgetDoctaviaDropdown<T>> createState() => _WidgetDoctaviaDropdownState<T>();
}

class _WidgetDoctaviaDropdownState<T> extends State<WidgetDoctaviaDropdown<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _isFocused ? theme.colorScheme.primary : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: DropdownButtonFormField<T>(
            initialValue: widget.value,
            items: widget.items,
            onChanged: widget.onChanged,
            validator: widget.validator,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: _isFocused ? theme.colorScheme.primary : AppColors.mutedForeground),
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: _isFocused ? theme.colorScheme.primary.withValues(alpha: 0.05) : AppColors.secondary.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
