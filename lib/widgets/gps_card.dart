import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

class GpsCard extends StatefulWidget {
  const GpsCard(this.lat, this.lng, {super.key});

  final double lat;
  final double lng;

  @override
  GpsCardState createState() => GpsCardState();
}

class GpsCardState extends State<GpsCard> {
  final MapController mapController = MapController();

  static const _interactionOptions = InteractionOptions(
    flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
  );

  bool _isFirstBuild = true;

  @override
  void didUpdateWidget(covariant GpsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isFirstBuild) {
      mapController.move(LatLng(widget.lat, widget.lng), 15.0);
      _isFirstBuild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
          initialCenter: LatLng(widget.lat, widget.lng),
          initialZoom: 13.0,
          interactionOptions: _interactionOptions),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(widget.lat, widget.lng),
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: const Icon(
                    Icons.location_on,
                    size: 50,
                    color: Colors.blue,
                  ),
                )),
          ],
        ),
      ],
    );
  }
}
