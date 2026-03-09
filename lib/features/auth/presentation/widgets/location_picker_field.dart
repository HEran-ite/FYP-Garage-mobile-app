import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/places_remote_datasource.dart';
import 'map_picker_screen.dart';

/// Picked location (address + optional coordinates + place_id for backend)
class PickedLocation {
  const PickedLocation({
    required this.address,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  final String address;
  final double? latitude;
  final double? longitude;
  final String? placeId;
}

/// Address field with Places autocomplete and optional map preview
class LocationPickerField extends StatefulWidget {
  const LocationPickerField({
    super.key,
    required this.label,
    required this.controller,
    required this.onLocationPicked,
    this.initialLat,
    this.initialLng,
    this.showMap = true,
    this.mapHeight = 160,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<PickedLocation> onLocationPicked;
  final double? initialLat;
  final double? initialLng;
  final bool showMap;
  final double mapHeight;

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

/// Default map center when no location is set yet
const LatLng _defaultMapCenter = LatLng(37.7749, -122.4194);

class _LocationPickerFieldState extends State<LocationPickerField> {
  final PlacesRemoteDataSource _places = PlacesRemoteDataSource();
  List<PlaceSuggestion> _suggestions = [];
  bool _loading = false;
  Timer? _debounce;
  double? _lat;
  double? _lng;
  bool _reverseGeocoding = false;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
  }

  @override
  void didUpdateWidget(covariant LocationPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLat != oldWidget.initialLat ||
        widget.initialLng != oldWidget.initialLng) {
      _lat = widget.initialLat;
      _lng = widget.initialLng;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _loading = true);
      final list = await _places.fetchAutocomplete(value);
      if (mounted) setState(() {
        _suggestions = list;
        _loading = false;
      });
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion s) async {
    setState(() {
      _suggestions = [];
      _loading = true;
    });
    final details = await _places.fetchPlaceDetails(s.placeId);
    if (!mounted) return;
    setState(() => _loading = false);
    if (details != null) {
      widget.controller.text = details.formattedAddress;
      _lat = details.lat;
      _lng = details.lng;
      widget.onLocationPicked(PickedLocation(
        address: details.formattedAddress,
        latitude: details.lat,
        longitude: details.lng,
        placeId: details.placeId,
      ));
    }
  }

  LatLng get _center {
    if (_lat != null && _lng != null) {
      return LatLng(_lat!, _lng!);
    }
    return _defaultMapCenter;
  }

  Future<void> _onPlaceholderTap() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute<LatLng>(
        builder: (context) => MapPickerScreen(
          initialLat: _lat,
          initialLng: _lng,
        ),
        fullscreenDialog: true,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _reverseGeocoding = true;
      _lat = result.latitude;
      _lng = result.longitude;
      _suggestions = [];
    });

    final geocodeResult = await _places.reverseGeocodeWithPlaceId(
      latitude: result.latitude,
      longitude: result.longitude,
    );
    if (!mounted) return;

    setState(() => _reverseGeocoding = false);
    final address = geocodeResult?.address ?? widget.controller.text.trim();
    if (geocodeResult != null && address.isNotEmpty) {
      widget.controller.text = address;
    }
    widget.onLocationPicked(PickedLocation(
      address: widget.controller.text.trim().isEmpty ? address : widget.controller.text.trim(),
      latitude: result.latitude,
      longitude: result.longitude,
      placeId: geocodeResult?.placeId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: 'Search address or enter manually',
            hintStyle: TextStyle(color: AppColors.inputIcon),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: AppColors.inputIcon,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            counterText: '',
          ),
          style: TextStyle(color: AppColors.textPrimary),
          maxLength: AuthConstants.maxAddressLength,
        ),
        if (_loading || _reverseGeocoding)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (_suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, i) {
                final s = _suggestions[i];
                return ListTile(
                  leading: const Icon(Icons.place, color: AppColors.inputIcon),
                  title: Text(
                    s.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _selectSuggestion(s),
                );
              },
            ),
          ),
        if (widget.showMap) ...[
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: _onPlaceholderTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              child: SizedBox(
                height: widget.mapHeight,
                child: _lat != null && _lng != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _center,
                              zoom: 15,
                            ),
                            onMapCreated: (_) {},
                            markers: {
                              Marker(
                                markerId: const MarkerId('garage'),
                                position: _center,
                                draggable: false,
                              ),
                            },
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                          ),
                          Positioned(
                            right: AppSpacing.sm,
                            bottom: AppSpacing.sm,
                            child: Material(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                              child: InkWell(
                                onTap: _onPlaceholderTap,
                                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                                child: const Padding(
                                  padding: EdgeInsets.all(AppSpacing.sm),
                                  child: Icon(Icons.edit_location_alt),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                AuthConstants.mapPreviewLabel,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                AuthConstants.mapTapToSetHint,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
