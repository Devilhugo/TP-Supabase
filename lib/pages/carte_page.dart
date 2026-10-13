import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config.dart';

class CartePage extends StatefulWidget {
  const CartePage({super.key});
  static const route = '/carte';

  @override
  State<CartePage> createState() => _MapOsmState();
}

class _MapOsmState extends State<CartePage> {
  // Greta GBS
  static const LatLng _greta = LatLng(AppConfig.gretaLat, AppConfig.gretaLng);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Center(child: Text('Cartographie')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: _greta,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'fr.vannes.tpsupabase',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _greta,
                width: 40,
                height: 40,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Greta Bretagne Sud - Vannes')),
                  ),
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 40),
                ),
              ),
            ],
          ),
          // Attribution obligatoire pour les tuiles OpenStreetMap
          const RichAttributionWidget(
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
        ],
      ),
    );
  }
}
