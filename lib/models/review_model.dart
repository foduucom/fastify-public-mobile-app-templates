class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> breakdown;

  ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.breakdown,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['breakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      breakdown[i] =
          int.tryParse(rawBreakdown[i.toString()]?.toString() ?? '0') ?? 0;
    }

    return ReviewSummary(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      breakdown: breakdown,
    );
  }
}

class Review {
  final String id;
  final String name;
  final String comment;
  final int rating;
  final DateTime? createdAt;
  final bool isMine;

  Review({
    required this.id,
    required this.name,
    required this.comment,
    required this.rating,
    this.createdAt,
    required this.isMine,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Anonymous',
      comment: json['comment'] ?? '',
      rating: json['rating'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      isMine: json['is_mine'] ?? false,
    );
  }
}

class ProductReviewsData {
  final ReviewSummary summary;
  final List<Review> reviews;

  ProductReviewsData({required this.summary, required this.reviews});

  factory ProductReviewsData.fromJson(Map<String, dynamic> json) {
    return ProductReviewsData(
      summary: ReviewSummary.fromJson(json['summary'] ?? {}),
      reviews: (json['reviews']?['docs'] as List? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
    );
  }
}
