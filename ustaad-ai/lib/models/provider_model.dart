/// Data model for the service provider (worker) using Ustaad.ai.
class ProviderModel {
  final String id;
  final String name;
  final double trustScore;
  final double todayEarnings;
  final bool isOnline;
  final List<String> skills;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.trustScore,
    required this.todayEarnings,
    required this.isOnline,
    required this.skills,
  });

  ProviderModel copyWith({
    String? id,
    String? name,
    double? trustScore,
    double? todayEarnings,
    bool? isOnline,
    List<String>? skills,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      trustScore: trustScore ?? this.trustScore,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      isOnline: isOnline ?? this.isOnline,
      skills: skills ?? this.skills,
    );
  }

  /// // TODO: ANTIGRAVITY HOOK — Replace with real JSON deserialization
  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      trustScore: (json['trust_score'] as num).toDouble(),
      todayEarnings: (json['today_earnings'] as num).toDouble(),
      isOnline: json['is_online'] as bool? ?? false,
      skills: List<String>.from(json['skills'] as List? ?? []),
    );
  }

  /// // TODO: ANTIGRAVITY HOOK — Replace with real JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trust_score': trustScore,
      'today_earnings': todayEarnings,
      'is_online': isOnline,
      'skills': skills,
    };
  }

  /// Mock provider for development
  static ProviderModel get mock => const ProviderModel(
        id: 'PRV-001',
        name: 'Muhammad Aslam',
        trustScore: 4.8,
        todayEarnings: 4500,
        isOnline: true,
        skills: ['AC Repair', 'Electrical Wiring', 'Plumbing'],
      );
}
