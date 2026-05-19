/// Data model for a customer review in Ustaad.ai.
class ReviewModel {
  final String id;
  final String customerName;
  final String serviceType;
  final double rating;
  final String comment;
  final String timeAgo;

  const ReviewModel({
    required this.id,
    required this.customerName,
    required this.serviceType,
    required this.rating,
    required this.comment,
    required this.timeAgo,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      serviceType: json['service_type'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      timeAgo: json['time_ago'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'service_type': serviceType,
      'rating': rating,
      'comment': comment,
      'time_ago': timeAgo,
    };
  }
}
