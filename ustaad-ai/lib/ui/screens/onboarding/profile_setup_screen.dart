import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustaad_ai/core/theme/colors.dart';
import 'package:ustaad_ai/providers/job_state_provider.dart';
import 'package:ustaad_ai/ui/widgets/custom_button.dart';
import 'package:ustaad_ai/ui/screens/onboarding/welcome_complete_screen.dart';

/// Profile setup screen — worker enters name, phone, and selects skills.
///
/// Designed for low-literacy users: large inputs, icon-driven skill chips,
/// minimal required fields.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final Set<String> _selectedSkills = {};
  bool _isSubmitting = false;

  // Available skills with icons and Urdu labels
  static const List<Map<String, dynamic>> _skills = [
    {'en': 'AC Repair', 'ur': 'اے سی مرمت', 'icon': Icons.ac_unit},
    {'en': 'Electrical', 'ur': 'بجلی کا کام', 'icon': Icons.electrical_services},
    {'en': 'Plumbing', 'ur': 'پلمبنگ', 'icon': Icons.plumbing},
    {'en': 'Painting', 'ur': 'پینٹنگ', 'icon': Icons.format_paint},
    {'en': 'Carpentry', 'ur': 'بڑھئی', 'icon': Icons.carpenter},
    {'en': 'Welding', 'ur': 'ویلڈنگ', 'icon': Icons.hardware},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _selectedSkills.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: ANTIGRAVITY HOOK — Send profile data to backend
    // await apiService.createProfile({
    //   'name': _nameController.text,
    //   'phone': _phoneController.text,
    //   'skills': _selectedSkills.toList(),
    // });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomeCompleteScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: [
                  _buildDot(true),
                  _buildLine(true),
                  _buildDot(true),
                  _buildLine(false),
                  _buildDot(false),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      isEnglish ? 'Setup Your Profile' : 'اپنا پروفائل بنائیں',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEnglish
                          ? 'Tell us about yourself so customers can find you'
                          : 'اپنے بارے میں بتائیں تاکہ کسٹمرز آپ کو ڈھونڈ سکیں',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name field
                    _buildLabel(isEnglish ? 'Full Name' : 'پورا نام', Icons.person),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: isEnglish ? 'e.g., Muhammad Aslam' : 'مثلاً محمد اسلم',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 24),

                    // Phone field
                    _buildLabel(isEnglish ? 'Phone Number' : 'فون نمبر', Icons.phone),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      hint: isEnglish ? '+92 300 1234567' : '+92 300 1234567',
                      keyboardType: TextInputType.phone,
                      prefixText: '+92 ',
                    ),
                    const SizedBox(height: 32),

                    // Skills selection
                    _buildLabel(
                      isEnglish ? 'Your Skills (select at least 1)' : 'آپ کے ہنر (کم از کم 1 منتخب کریں)',
                      Icons.build,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _skills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill['en']);
                        return _SkillChip(
                          label: isEnglish ? skill['en'] : skill['ur'],
                          icon: skill['icon'] as IconData,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSkills.remove(skill['en']);
                              } else {
                                _selectedSkills.add(skill['en'] as String);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Submit button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: CustomButton(
                label: isEnglish ? 'Continue' : 'آگے بڑھیں',
                subLabel: isEnglish ? 'آگے بڑھیں' : 'Continue',
                icon: Icons.arrow_forward,
                isLoading: _isSubmitting,
                backgroundColor: (_nameController.text.trim().isNotEmpty &&
                        _phoneController.text.trim().isNotEmpty &&
                        _selectedSkills.isNotEmpty)
                    ? AppColors.primary
                    : AppColors.surfaceLight,
                textColor: (_nameController.text.trim().isNotEmpty &&
                        _phoneController.text.trim().isNotEmpty &&
                        _selectedSkills.isNotEmpty)
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
                minHeight: 64,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      onChanged: (_) => setState(() {}), // Rebuild to update button state
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          fontSize: 16,
        ),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
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

/// Icon-driven skill selection chip for easy touch targets.
class _SkillChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkillChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
