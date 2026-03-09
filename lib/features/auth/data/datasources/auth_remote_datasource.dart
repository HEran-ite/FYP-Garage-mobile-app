import 'dart:typed_data';

import '../models/registration_model.dart';
import '../models/user_model.dart';

/// Remote data source for auth (API calls).
/// Backend: driver-garage-backend branch Garage-profile-Yordi.
abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register(
    RegistrationModel registration, {
    Uint8List? licenseBytes,
    String? licenseFileName,
  });
  Future<UserModel?> getCurrentUser();
}
