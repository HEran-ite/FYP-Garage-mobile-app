import 'garage_rating_model.dart';

class GarageReviewsResponseModel {
  const GarageReviewsResponseModel({
    required this.averageRating,
    required this.totalRatings,
    required this.reviews,
  });

  final double averageRating;
  final int totalRatings;
  final List<GarageRatingModel> reviews;

  factory GarageReviewsResponseModel.fromJson(Map<String, dynamic> json) {
    final averageRaw = json['averageRating'];
    final totalRaw = json['totalRatings'];
    final reviewsRaw = json['reviews'];

    final averageRating = averageRaw is num
        ? averageRaw.toDouble()
        : double.tryParse(averageRaw?.toString() ?? '') ?? 0.0;
    final totalRatings = totalRaw is num
        ? totalRaw.toInt()
        : int.tryParse(totalRaw?.toString() ?? '') ?? 0;

    final reviews = (reviewsRaw is List ? reviewsRaw : const <dynamic>[])
        .whereType<Map>()
        .map((e) => GarageRatingModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return GarageReviewsResponseModel(
      averageRating: averageRating,
      totalRatings: totalRatings,
      reviews: reviews,
    );
  }
}
