abstract class GarageSettingsRemoteDataSource {
  /// Backend: GET /garages/settings. Returns JSON object.
  Future<Map<String, dynamic>> getSettings();

  /// Backend: PUT /garages/settings with a partial JSON object; backend merges it.
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> patch);
}

