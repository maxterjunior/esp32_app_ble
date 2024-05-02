import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:esp32_app/device_page.dart';
import 'package:esp32_app/helpers/database.dart';
import 'package:esp32_app/screens/visualize_data.dart';
import 'package:esp32_app/utils/snackbar.dart';
import 'package:esp32_app/widgets/next_screen.dart';
import 'package:esp32_app/widgets/target_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';

class ConnectToDevice extends StatefulWidget {
  const ConnectToDevice({super.key});

  @override
  State<ConnectToDevice> createState() => _ConnectToDeviceState();
}

class _ConnectToDeviceState extends State<ConnectToDevice> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      print('Error: $e');
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
    onRefresh();
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 20.0,
                ),
                child: Text(
                  '¡Bienvenido Dev!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Target(
                  title: 'Conecte su dispositivo',
                  content: listDevices(),
                  height: MediaQuery.of(context).size.height * 0.6),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _exportDB,
                      child: const Icon(Icons.share),
                    ),
                    ElevatedButton(
                        onPressed: (() => {
                          nextScreenReplace(
                            context,
                            const VisualizeData(),
                            PageTransitionType.rightToLeft,
                          )
                        }),
                        child: const Icon(Icons.data_usage)),
                    ElevatedButton(
                      onPressed: _clearBD,
                      child: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listDevices() {
    return RefreshIndicator(
      color: Theme.of(context).focusColor,
      displacement: 20.0,
      onRefresh: onRefresh,
      child: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        children: [
          _scanResults.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Sin dispositivos encontrados'),
                )
              : Column(
                  children: _scanResults.map((r) {
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 25.0),
                      title: Text(
                        r.device.platformName != ''
                            ? r.device.platformName
                            : 'Desconocido',
                        style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(r.device.remoteId.toString()),
                      trailing: ElevatedButton(
                        child: const Text('Conectar'),
                        onPressed: () {
                          r.device.connect();
                          nextScreenReplace(
                            context,
                            DeviceScreen(device: r.device, isConnected: false),
                            PageTransitionType.rightToLeft,
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(seconds: 15));
  }



  void _exportDB() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    DatabaseHelper.instance.queryAllRows().then((value) async {
      String val = jsonEncode(value);

      // Comparte el archivo
      final shareResult = await Share.shareXFiles([
        XFile.fromData(
          Uint8List.fromList(val.codeUnits),
          name: 'my_data.txt',
          mimeType: 'application/json',
          // mimeType: 'text/plain',
        ),
      ]);

      scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
    });
  }

  void _clearBD() async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continuar"),
      onPressed: () async {
        Navigator.of(context).pop();
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        await DatabaseHelper.instance.deleteAll();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Base de datos eliminada'),
            duration: Duration(seconds: 5),
          ),
        );
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Borrar base de datos"),
      content: const Text("¿Está seguro de guardar todos los datos?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Share result: ${result.status}"),
          if (result.status == ShareResultStatus.success)
            Text("Shared to: ${result.raw}")
        ],
      ),
    );
  }
}
