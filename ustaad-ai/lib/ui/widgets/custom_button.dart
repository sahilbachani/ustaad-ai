import 'package:flutter/material.dart';
import 'package:ustaad_ai/core/theme/colors.dart';

/// A large, high-contrast action button designed for easy touch targets.
///
/// Minimum height: 64px. Supports loading state with a spinner.
/// Used as the primary CTA across all screens.
class CustomButton extends StatelessWidget {
  final String label;
  final String? subLabel; // For bilingual text (e.g., Urdu below English)
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final bool isLoading;
  final double minHeight;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    this.subLabel,
    this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    this.icon,
    this.isLoading = false,
    this.minHeight = 64,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: textColor.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 3,
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            subLabel!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
