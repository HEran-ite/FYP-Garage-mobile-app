import 'dart:typed_data';

import '../models/garage_service_item.dart';
import '../models/registration_model.dart';
import '../models/user_model.dart';

/// Remote data source for auth (API calls).
/// Backend: driver-garage-backend branch Garage-profile-Yordi.
abstract class AuthRemoteDataSource {
  String? get authToken;
  void setAuthToken(String? token);
  void clearAuthToken();

  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register(
    RegistrationModel registration, {
    Uint8List? licenseBytes,
    String? licenseFileName,
  });
  Future<UserModel?> getCurrentUser();

  /// Fetch full garage profile including services (GET /garage/profile).
  Future<UserModel> getProfile();

  /// Update current garage profile (backend: PATCH /garages/me).
  Future<UserModel> updateProfile(UserModel user);

  /// List my services (GET /garages/me/services).
  Future<List<GarageServiceItem>> listGarageServices();

  /// Create one service (POST /garages/me/services). Body: { name: string }.
  Future<GarageServiceItem> createGarageService(String name);

  /// Delete one service (DELETE /garages/me/services/:serviceId).
  Future<void> deleteGarageService(String serviceId);

  /// Replace full services list (PUT /garages/me/services) with service names.
  Future<void> replaceGarageServices(List<String> services);
}
