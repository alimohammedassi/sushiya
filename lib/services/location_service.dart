import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationServiceResult {
  final double latitude;
  final double longitude;
  final String? address;
  LocationServiceResult({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class LocationService {
  static Future<LocationServiceResult> getCurrent() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    String? address;
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => (s ?? '').toString().trim().isNotEmpty).join(', ');
      }
    } catch (_) {}

    return LocationServiceResult(
      latitude: pos.latitude,
      longitude: pos.longitude,
      address: address,
    );
  }
}
