// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert' show utf8;

import 'package:esp32_app/helpers/database.dart';
import 'package:esp32_app/screens/connect_to_device.dart';
import 'package:esp32_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:page_transition/page_transition.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({
    super.key,
    required this.device,
    required this.isConnected,
  });

  final BluetoothDevice device;
  final bool isConnected;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final String serviceGpsUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String charactGpsUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  late Stream<List<int>>? streamGps;

  late bool isReady;
  late bool hasError = false;
  double velocidad = 0.0;
  double distAct = 0.0;
  double distAnt = 0.0;

  late List<Widget> listWidgets = [
    Target(title: 'GPS', content: _widget(streamGps!, _gps)),
  ];

  StreamSubscription? _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectDevice();
  }

  @override
  void dispose() {
    streamGps = null;
    _lastValueSubscription?.cancel();
    super.dispose();
  }

  void connectDevice() async {
    if (!widget.isConnected) {
      await widget.device
          .connect()
          .whenComplete(() => discoverServices())
          .catchError((e) {
        hasError = true;
        setState(() {});
      });
    } else {
      discoverServices();
    }
  }

  void discoverServices() async {
    try {
      List<BluetoothService> services = await widget.device.discoverServices();
      bool findService = false;
      for (var service in services) {
        print('Service: ${service.uuid}');
        if (service.uuid.toString() == serviceGpsUuid) {
          findService = true;
          print('Service found: ${service.uuid}');
          for (var characteristic in service.characteristics) {
            print('Characteristic: ${characteristic.uuid}');
            if (characteristic.uuid.toString() == charactGpsUuid) {
              streamGps = characteristic.lastValueStream;

              // Guardar los datos en la base de datos
              _lastValueSubscription?.cancel();
              _lastValueSubscription = streamGps!.listen((value) {
                var data = utf8.decode(value);
                if (data.isEmpty || data == '') return;
                var gpsData = data.split(',');
                if (gpsData.length == 2) {
                  var lat = double.parse(gpsData[0]);
                  var lng = double.parse(gpsData[1]);
                  DatabaseHelper.instance.insert({
                    DatabaseHelper.columnLat: lat,
                    DatabaseHelper.columnLong: lng,
                  });
                }
              });

              isReady = true;
              setState(() {});
            }
            await characteristic.setNotifyValue(!characteristic.isNotifying);
          }
        }
      }
      if (!findService) {
        hasError = true;
        setState(() {});
      }
    } catch (e) {
      print('Error discoverServices: $e');
      hasError = true;
      setState(() {});
    }
  }

  Widget _gps(gpsValue) {
    var lat = 0.0;
    var lng = 0.0;
    if (gpsValue != "") {
      var data = gpsValue.split(',');
      if (data.length == 2) {
        lat = double.parse(data[0]);
        lng = double.parse(data[1]);
      }
    }
    return GpsCard(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              _appBar(),
              Expanded(
                  child: hasError
                      ? const Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error,
                                  size: 50,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 10),
                                Text('Error al conectar con el dispositivo'),
                              ],
                            ),
                          ),
                        )
                      : isReady
                          ? gridList(listWidgets)
                          : _waiting()),
              const Text('❤ por Mj.asm'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),
            Text(
              widget.device.platformName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text('Demo BLE - Gps / Gnss',
                style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
        const Expanded(child: SizedBox()),
        StreamBuilder<BluetoothConnectionState>(
          stream: widget.device.connectionState,
          initialData: BluetoothConnectionState.disconnected,
          builder: (c, snapshot) {
            onPressed() {
              widget.device.disconnect();
              streamGps = null;
              _lastValueSubscription?.cancel();
              nextScreenReplace(
                context,
                const ConnectToDevice(),
                PageTransitionType.leftToRight,
              );
            }

            Color color = Colors.white;
            if (snapshot.data == BluetoothConnectionState.disconnected) {
              color = Colors.red;
            } else if (snapshot.data == BluetoothConnectionState.connected ||
                hasError) {
              color = Colors.green;
            }
            return IconButton(
              iconSize: 28.0,
              onPressed: onPressed,
              icon: Icon(
                Icons.power_settings_new_rounded,
                color: color,
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _widget(Stream<List<int>> stream, Function widget) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          var currentValue = _dataParser(snapshot.data!);
          return widget(currentValue);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('error: ${snapshot.error}');
        }
        return const Text('Check the stream');
      },
    );
  }

  _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  _waiting() {
    return const Center(child: CircularProgressIndicator());
  }
}
