import 'package:geolocator/geolocator.dart';

class LocationService {
  // Troque estas coordenadas pelo endereço real da empresa.
  static const double empresaLatitude = -23.550520;
  static const double empresaLongitude = -46.633308;
  static const double raioPermitidoMetros = 100.0;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'O serviço de localização está desativado.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'As permissões de localização foram negadas.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'As permissões de localização foram negadas permanentemente.';
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  double distanceFromWorkplace(Position position) {
    // A distância é calculada em metros pelo próprio geolocator.
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      empresaLatitude,
      empresaLongitude,
    );
  }
}
