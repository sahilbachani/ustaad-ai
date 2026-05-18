import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustaad_ai/core/theme/colors.dart';
import 'package:ustaad_ai/providers/job_state_provider.dart';
import 'package:ustaad_ai/ui/widgets/custom_button.dart';
import 'package:ustaad_ai/ui/screens/dashboard_screen.dart';

/// Final onboarding screen — "You're all set!" success state.
///
/// Shows a celebration animation then takes the user to the main dashboard.
class WelcomeCompleteScreen extends ConsumerWidget {
  const WelcomeCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnglish = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              // Progress indicator — all complete
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    _buildDot(true),
                    _buildLine(true),
                    _buildDot(true),
                    _buildLine(true),
                    _buildDot(true),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Success animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (_, value, child) => Transform.scale(
                  scale: value,
                  child: child,
                ),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 72,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                isEnglish ? "You're All Set!" : '!سب تیار ہے',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isEnglish
                    ? 'Your profile is ready. Start accepting jobs and earning today!'
                    : 'آپ کا پروفائل تیار ہے۔ آج ہی کام قبول کرنا شروع کریں!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Go to Dashboard
              CustomButton(
                label: isEnglish ? 'Go to Dashboard' : 'ڈیش بورڈ پر جائیں',
                subLabel: isEnglish ? 'ڈیش بورڈ پر جائیں' : 'Go to Dashboard',
                icon: Icons.dashboard,
                backgroundColor: AppColors.primary,
                textColor: AppColors.textOnPrimary,
                minHeight: 72,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const DashboardScreen(),
                      transitionDuration: const Duration(milliseconds: 500),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                    (_) => false, // Remove all previous routes
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? AppColors.primary : AppColors.divider,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildLine(bool active) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: active ? AppColors.primary : AppColors.divider,
      ),
    );
  }
}
