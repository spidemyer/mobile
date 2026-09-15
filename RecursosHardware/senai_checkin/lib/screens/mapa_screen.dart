import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;

  // Coordenadas de exemplo
  final LatLng _senaiLocation = const LatLng(-22.7394, -47.3316);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização do SENAI'),
        backgroundColor: Colors.red[750], // Cor comum temática ou padrão
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _senaiLocation,
          zoom: 16.0, // Nível de zoom do mapa
        ),
        markers: {
          Marker(
            markerId: const MarkerId('senai_marker'),
            position: _senaiLocation,
            infoWindow: const InfoWindow(
              title: 'SENAI',
              snippet: 'Local de Check-in',
            ),
          ),
        },
      ),
    );
  }
}