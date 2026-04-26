import '../models/garage_reviews_response_model.dart';

abstract class GarageRatingsRemoteDataSource {
  Future<GarageReviewsResponseModel> getMyReviews();
}
