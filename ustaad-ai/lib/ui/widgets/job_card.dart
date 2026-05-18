import 'package:flutter/material.dart';
import 'package:ustaad_ai/core/theme/colors.dart';
import 'package:ustaad_ai/models/job_model.dart';
import 'package:ustaad_ai/ui/widgets/status_badge.dart';

/// A card widget displaying a job summary in the dashboard list.
///
/// Shows service type icon, location, payout, and status badge.
/// Tapping navigates to the job detail screen.
class JobCard extends StatelessWidget {
  final JobModel job;
  final bool isEnglish;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.isEnglish = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Service type icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _serviceIcon,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // Job details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service type
                    Text(
                      isEnglish ? job.serviceType : job.serviceTypeUrdu,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isEnglish ? job.location : job.locationUrdu,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Payout + Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs ${job.estimatedPayout.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        StatusBadge(
                          status: job.status,
                          isEnglish: isEnglish,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Maps service type to a Material icon.
  IconData get _serviceIcon {
    switch (job.serviceType.toLowerCase()) {
      case 'ac repair':
        return Icons.ac_unit;
      case 'electrical wiring':
        return Icons.electrical_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'painting':
        return Icons.format_paint;
      default:
        return Icons.build;
    }
  }
}
