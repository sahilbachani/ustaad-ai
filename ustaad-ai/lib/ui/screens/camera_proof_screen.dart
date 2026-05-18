import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ustaad_ai/core/theme/colors.dart';
import 'package:ustaad_ai/core/localization/english_strings.dart';
import 'package:ustaad_ai/core/localization/urdu_strings.dart';
import 'package:ustaad_ai/providers/job_state_provider.dart';
import 'package:ustaad_ai/ui/widgets/custom_button.dart';

/// Simulated camera proof upload screen.
///
/// Fully optimized to run on Mobile, Desktop, and Flutter Web using in-memory bytes.
class CameraProofScreen extends ConsumerStatefulWidget {
  final String jobId;
  const CameraProofScreen({super.key, required this.jobId});

  @override
  ConsumerState<CameraProofScreen> createState() => _CameraProofScreenState();
}

class _CameraProofScreenState extends ConsumerState<CameraProofScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedXFile;
  Uint8List? _imageBytes;
  bool _isUploading = false;
  bool _isSuccess = false;

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 80,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _selectedXFile = photo;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      // Fallback to gallery if camera unavailable (e.g. on emulators / web without camera prompt)
      _pickFromGallery();
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 80,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _selectedXFile = photo;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      print('[CameraProofScreen] Error picking image: $e');
    }
  }

  Future<void> _submitProof() async {
    if (_selectedXFile == null) return;

    setState(() => _isUploading = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.uploadCompletionProof(widget.jobId, _selectedXFile!);
      await ref.read(activeJobProvider.notifier).completeJob();

      setState(() {
        _isUploading = false;
        _isSuccess = true;
      });

      // Auto-navigate back after success
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context); // Back to job detail
        Navigator.pop(context); // Back to dashboard
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(localeProvider)
                ? EnglishStrings.error
                : UrduStrings.error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          isEnglish ? EnglishStrings.cameraProof : UrduStrings.cameraProof,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isSuccess ? _buildSuccess(isEnglish) : _buildForm(isEnglish),
    );
  }

  Widget _buildSuccess(bool isEnglish) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 56),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isEnglish ? EnglishStrings.proofSubmitted : UrduStrings.proofSubmitted,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.success),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isEnglish) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Image preview area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          isEnglish ? EnglishStrings.noImageSelected : UrduStrings.noImageSelected,
                          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          // Camera / Gallery buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: isEnglish ? EnglishStrings.takePhoto : UrduStrings.takePhoto,
                  icon: Icons.camera_alt,
                  backgroundColor: AppColors.surfaceLight,
                  textColor: AppColors.textPrimary,
                  minHeight: 56,
                  onPressed: _takePhoto,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: isEnglish ? EnglishStrings.chooseFromGallery : UrduStrings.chooseFromGallery,
                  icon: Icons.photo_library,
                  backgroundColor: AppColors.surfaceLight,
                  textColor: AppColors.textPrimary,
                  minHeight: 56,
                  onPressed: _pickFromGallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Submit button
          CustomButton(
            label: isEnglish ? EnglishStrings.submitProof : UrduStrings.submitProof,
            subLabel: isEnglish ? 'ثبوت جمع کروائیں' : 'Submit Proof',
            icon: Icons.cloud_upload,
            backgroundColor: _imageBytes != null ? AppColors.primary : AppColors.surfaceLight,
            textColor: _imageBytes != null ? AppColors.textOnPrimary : AppColors.textSecondary,
            isLoading: _isUploading,
            minHeight: 72,
            onPressed: _imageBytes != null ? _submitProof : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
