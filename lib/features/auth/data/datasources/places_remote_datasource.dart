import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/maps_config.dart';

/// Place suggestion from autocomplete
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
  });

  final String placeId;
  final String description;
}

/// Fetches place details (lat/lng, place_id) by place ID
class PlaceDetails {
  const PlaceDetails({
    required this.lat,
    required this.lng,
    required this.formattedAddress,
    this.placeId,
  });

  final double lat;
  final double lng;
  final String formattedAddress;
  final String? placeId;
}

/// Remote data source for Google Places (autocomplete + place details)
class PlacesRemoteDataSource {
  PlacesRemoteDataSource({String? apiKey})
      : _apiKey = apiKey ?? kGoogleMapsApiKey;

  final String _apiKey;
  static const String _autocompleteBase =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _detailsBase =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String _geocodeBase =
      'https://maps.googleapis.com/maps/api/geocode/json';

  /// Legacy Places Autocomplete (returns place_id + description)
  Future<List<PlaceSuggestion>> fetchAutocomplete(String input) async {
    if (input.trim().isEmpty) return [];
    final uri = Uri.parse(_autocompleteBase).replace(
      queryParameters: {
        'input': input.trim(),
        'key': _apiKey,
        'types': 'address',
      },
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return [];
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final predictions = json['predictions'] as List<dynamic>? ?? [];
    return predictions
        .map((e) => PlaceSuggestion(
              placeId: e['place_id'] as String,
              description: e['description'] as String,
            ))
        .toList();
  }

  /// Place details to get lat/lng and formatted address (and place_id)
  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    final uri = Uri.parse(_detailsBase).replace(
      queryParameters: {
        'place_id': placeId,
        'key': _apiKey,
        'fields': 'geometry,formatted_address,place_id',
      },
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final result = json['result'] as Map<String, dynamic>?;
    if (result == null) return null;
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    if (location == null) return null;
    final lat = (location['lat'] as num).toDouble();
    final lng = (location['lng'] as num).toDouble();
    final formattedAddress =
        result['formatted_address'] as String? ?? '$lat,$lng';
    final resultPlaceId = result['place_id'] as String? ?? placeId;
    return PlaceDetails(
      lat: lat,
      lng: lng,
      formattedAddress: formattedAddress,
      placeId: resultPlaceId,
    );
  }

  /// Reverse geocode lat/lng to a formatted address.
  /// Returns null if the API fails or no results found.
  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final result = await reverseGeocodeWithPlaceId(
      latitude: latitude,
      longitude: longitude,
    );
    return result?.address;
  }

  /// Reverse geocode lat/lng to address and place_id (for backend garage_location).
  /// Returns null if the API fails or no results found.
  Future<({String address, String placeId})?> reverseGeocodeWithPlaceId({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_geocodeBase).replace(
      queryParameters: {
        'latlng': '${latitude.toString()},${longitude.toString()}',
        'key': _apiKey,
      },
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['status'] != 'OK') return null;
    final results = json['results'] as List<dynamic>? ?? [];
    if (results.isEmpty) return null;
    final first = results.first as Map<String, dynamic>;
    final address = first['formatted_address'] as String? ?? '';
    final placeId = first['place_id'] as String? ?? '';
    return (address: address, placeId: placeId);
  }
}
