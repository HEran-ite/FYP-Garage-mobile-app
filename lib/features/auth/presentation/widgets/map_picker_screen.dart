import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/places_remote_datasource.dart';

/// Default center when no location is set
const LatLng _defaultCenter = LatLng(37.7749, -122.4194);

/// Full-screen map picker. User drags the pin or taps the map, then confirms.
/// Pops with selected [LatLng] only after explicit confirm.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  final double? initialLat;
  final double? initialLng;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _position;
  final PlacesRemoteDataSource _places = PlacesRemoteDataSource();
  GoogleMapController? _mapController;
  bool _myLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialLat != null && widget.initialLng != null
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _defaultCenter;
    if (widget.initialLat == null || widget.initialLng == null) {
      _initFromDeviceLocation();
    }
  }

  Future<void> _initFromDeviceLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationSnackBar(
        message:
            'Location services are turned off. Turn on device location to use your current position.',
        actionLabel: 'Settings',
        onAction: Geolocator.openLocationSettings,
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showLocationSnackBar(
        message:
            'Location permission was denied. Enable it in app settings to use your current position.',
        actionLabel: 'Settings',
        onAction: Geolocator.openAppSettings,
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationSnackBar(
        message:
            'Location permission is permanently denied. Open app settings to allow location access.',
        actionLabel: 'Settings',
        onAction: Geolocator.openAppSettings,
      );
      return;
    }

    if (mounted) {
      setState(() => _myLocationEnabled = true);
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 6),
      );
      await _updateMapPosition(LatLng(pos.latitude, pos.longitude));
      return;
    } catch (_) {
      // Fall back to last known position before keeping static defaults.
    }

    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        await _updateMapPosition(LatLng(lastKnown.latitude, lastKnown.longitude));
      }
    } catch (_) {
      // Keep static default center when no device position can be resolved.
    }
  }

  Future<void> _updateMapPosition(LatLng next) async {
    if (!mounted) return;
    setState(() => _position = next);
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: next, zoom: 15),
      ),
    );
  }

  void _showLocationSnackBar({
    required String message,
    required String actionLabel,
    required Future<bool> Function() onAction,
  }) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: actionLabel,
          onPressed: () {
            onAction();
          },
        ),
      ),
    );
  }

  Future<void> _onDone() async {
    // Show loading while fetching address
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.md),
                Text(AuthConstants.mapLoadingAddress),
              ],
            ),
          ),
        ),
      ),
    );
    final address = await _places.reverseGeocode(
      latitude: _position.latitude,
      longitude: _position.longitude,
    );
    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss loading dialog
    final addressDisplay = address?.trim().isNotEmpty == true
        ? address!
        : AuthConstants.mapAddressUnavailable;

    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AuthConstants.mapConfirmLocationTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                addressDisplay,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AuthConstants.mapDriverVisibilityMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AuthConstants.mapSetCarefullyMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.inputBorder),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text(
                        AuthConstants.mapChangeLocationButton,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(_position);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryButtonText,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text(AuthConstants.mapConfirmButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AuthConstants.mapSelectLocationAppBarTitle),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TextButton(
              onPressed: _onDone,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _position,
              zoom: 15,
            ),
            onMapCreated: (c) => _mapController = c,
            markers: {
              Marker(
                markerId: const MarkerId('garage'),
                position: _position,
                draggable: true,
                onDragEnd: (LatLng pos) {
                  setState(() => _position = pos);
                },
              ),
            },
            onTap: (LatLng pos) {
              setState(() => _position = pos);
            },
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: _myLocationEnabled,
            zoomControlsEnabled: true,
          ),
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Text(
              AuthConstants.mapDragOrTapHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    backgroundColor: AppColors.surface,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
