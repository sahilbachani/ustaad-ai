import 'package:flutter/material.dart';
import 'package:ustaad_ai/core/theme/colors.dart';
import 'package:ustaad_ai/models/job_model.dart';

/// Colored pill-shaped badge that reflects the current [JobStatus].
class StatusBadge extends StatelessWidget {
  final JobStatus status;
  final bool isEnglish;

  const StatusBadge({
    super.key,
    required this.status,
    this.isEnglish = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor, width: 1.5),
      ),
      child: Text(
        _statusLabel,
        style: TextStyle(
          color: _statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (status) {
      case JobStatus.pending:
        return AppColors.statusPending;
      case JobStatus.accepted:
        return AppColors.statusAccepted;
      case JobStatus.arrived:
        return AppColors.statusArrived;
      case JobStatus.completed:
        return AppColors.statusCompleted;
    }
  }

  String get _statusLabel {
    switch (status) {
      case JobStatus.pending:
        return isEnglish ? 'PENDING' : 'زیرِ التوا';
      case JobStatus.accepted:
        return isEnglish ? 'ACCEPTED' : 'قبول شدہ';
      case JobStatus.arrived:
        return isEnglish ? 'ARRIVED' : 'پہنچ گیا';
      case JobStatus.completed:
        return isEnglish ? 'COMPLETED' : 'مکمل';
    }
  }
}
