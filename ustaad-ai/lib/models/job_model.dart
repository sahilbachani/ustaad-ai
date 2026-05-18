/// Represents the lifecycle state of a job.
enum JobStatus {
  pending,
  accepted,
  arrived,
  completed,
}

/// Data model for a single job in Ustaad.ai.
///
/// Each job moves through the state machine:
/// pending → accepted → arrived → completed
class JobModel {
  final String id;
  final String serviceType;
  final String serviceTypeUrdu;
  final String location;
  final String locationUrdu;
  final double estimatedPayout;
  final JobStatus status;
  final String customerName;
  final String customerPhone;
  final DateTime createdAt;

  const JobModel({
    required this.id,
    required this.serviceType,
    required this.serviceTypeUrdu,
    required this.location,
    required this.locationUrdu,
    required this.estimatedPayout,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.createdAt,
  });

  /// Creates a copy with selected fields overridden.
  JobModel copyWith({
    String? id,
    String? serviceType,
    String? serviceTypeUrdu,
    String? location,
    String? locationUrdu,
    double? estimatedPayout,
    JobStatus? status,
    String? customerName,
    String? customerPhone,
    DateTime? createdAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      serviceTypeUrdu: serviceTypeUrdu ?? this.serviceTypeUrdu,
      location: location ?? this.location,
      locationUrdu: locationUrdu ?? this.locationUrdu,
      estimatedPayout: estimatedPayout ?? this.estimatedPayout,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// // TODO: ANTIGRAVITY HOOK — Replace with real JSON deserialization
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      serviceType: json['service_type'] as String,
      serviceTypeUrdu: json['service_type_urdu'] as String? ?? '',
      location: json['location'] as String,
      locationUrdu: json['location_urdu'] as String? ?? '',
      estimatedPayout: (json['estimated_payout'] as num).toDouble(),
      status: JobStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => JobStatus.pending,
      ),
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// // TODO: ANTIGRAVITY HOOK — Replace with real JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_type': serviceType,
      'service_type_urdu': serviceTypeUrdu,
      'location': location,
      'location_urdu': locationUrdu,
      'estimated_payout': estimatedPayout,
      'status': status.name,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
