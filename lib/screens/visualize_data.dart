import 'package:esp32_app/screens/connect_to_device.dart';
import 'package:esp32_app/widgets/next_screen.dart';
import 'package:esp32_app/widgets/target_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:esp32_app/helpers/database.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'package:page_transition/page_transition.dart';

class VisualizeData extends StatefulWidget {
  const VisualizeData({super.key});

  @override
  VisualizeDataState createState() => VisualizeDataState();
}

class VisualizeDataState extends State<VisualizeData> {
  final MapController mapController = MapController();

  static const _interactionOptions = InteractionOptions(
    flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
  );

  bool loading = true;
  int count = 0;

  final List<LatLng> _points = [];

  void getdata() async {
    _points.clear();
    final allRows = await DatabaseHelper.instance.queryAllRows();
    loading = false;
    setState(() {});

    // Delay to allow the map to load
    await Future.delayed(const Duration(milliseconds: 100));
    count = allRows.length;

    if (allRows.isNotEmpty) {
      final row = allRows.last;
      mapController.move(
          LatLng(row[DatabaseHelper.columnLat], row[DatabaseHelper.columnLong]),
          15.0);
    }
    for (var row in allRows) {
      _points.add(LatLng(
          row[DatabaseHelper.columnLat], row[DatabaseHelper.columnLong]));
    }
    loading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !loading
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 10.0,
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          // Return to the previous screen
                                          nextScreenReplace(
                                              context,
                                              const ConnectToDevice(),
                                              PageTransitionType.rightToLeft);
                                        },
                                        icon: const Icon(Icons.arrow_back)),
                                    const SizedBox(width: 10),
                                    const Text('Visualize Data',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ))
                                  ]))
                          : const Text(''),
                      loading
                          ? const Center(child: CircularProgressIndicator())
                          : Target(
                              title: 'Total Points: $count',
                              content: FlutterMap(
                                mapController: mapController,
                                options: const MapOptions(
                                    initialCenter: LatLng(0, 0),
                                    initialZoom: 13.0,
                                    interactionOptions: _interactionOptions),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: _points,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              height: MediaQuery.of(context).size.height * 0.7)
                    ]))));
  }
}
