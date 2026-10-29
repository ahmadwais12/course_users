import 'package:flutter/material.dart';
import 'package:course_users/ui/ui_helper.dart';

enum ButtonVariant { filled, outlined, text, gradient }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? color;
  final Color? textColor;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.variant = ButtonVariant.filled,
    this.onPressed,
    this.loading = false,
    this.color,
    this.textColor,
    this.height,
    this.width,
    this.padding,
  });

  factory AppButton.filled({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool loading = false,
    Color? color,
    double? width,
  }) =>
      AppButton(
        label: label, icon: icon, onPressed: onPressed,
        loading: loading, color: color, width: width,
      );

  factory AppButton.outlined({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool loading = false,
    double? width,
  }) =>
      AppButton(
        label: label, icon: icon, variant: ButtonVariant.outlined,
        onPressed: onPressed, loading: loading, width: width,
      );

  factory AppButton.gradient({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool loading = false,
    double? width,
  }) =>
      AppButton(
        label: label, icon: icon, variant: ButtonVariant.gradient,
        onPressed: onPressed, loading: loading, width: width,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveTextColor = textColor ?? theme.colorScheme.onPrimary;
    final effectiveHeight = height ?? 52;
    final effectivePadding = padding ?? AppPad.sym16;

    switch (variant) {
      case ButtonVariant.filled:
        return SizedBox(
          height: effectiveHeight,
          width: width ?? double.infinity,
          child: FilledButton(
            onPressed: loading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: effectiveColor,
              foregroundColor: effectiveTextColor,
              padding: effectivePadding,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _buildContent(theme),
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          height: effectiveHeight,
          width: width ?? double.infinity,
          child: OutlinedButton(
            onPressed: loading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: effectiveColor,
              side: BorderSide(color: theme.dividerColor),
              padding: effectivePadding,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _buildContent(theme),
          ),
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: loading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: effectiveColor,
            padding: effectivePadding,
          ),
          child: _buildContent(theme),
        );
      case ButtonVariant.gradient:
        return SizedBox(
          height: effectiveHeight,
          width: width ?? double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [effectiveColor, theme.colorScheme.tertiary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: loading ? null : onPressed,
                child: Center(
                  child: _buildContent(theme),
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildContent(ThemeData theme) {
    if (loading) {
      return const SizedBox(
        width: 24, height: 24,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          Gap.w8,
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
    }
    return Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }
}
