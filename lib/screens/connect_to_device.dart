import 'dart:typed_data';

import 'package:esp32_app/device_page.dart';
import 'package:esp32_app/helpers/database.dart';
import 'package:esp32_app/widgets/next_screen.dart';
import 'package:esp32_app/widgets/target_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';

class ConnectToDevice extends StatefulWidget {
  const ConnectToDevice({Key? key}) : super(key: key);

  @override
  State<ConnectToDevice> createState() => _ConnectToDeviceState();
}

class _ConnectToDeviceState extends State<ConnectToDevice> {
  @override
  void initState() {
    super.initState();
    FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 2));
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
                      child: const Text('Exportar BD'),
                    ),
                    ElevatedButton(
                      onPressed: _clearBD,
                      child: const Text('Limpiar BD'),
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
      onRefresh: () => FlutterBluePlus.instance.startScan(
        timeout: const Duration(seconds: 1),
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        children: [
          StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.instance.scanResults,
            initialData: const [],
            builder: (c, snapshot) => Column(
              children: snapshot.data!.map((r) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
                  title: Text(
                      r.device.name != '' ? r.device.name : 'Desconocido',
                      style: const TextStyle(
                          fontSize: 17.0, fontWeight: FontWeight.bold)),
                  subtitle: Text(r.device.id.toString()),
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
          )
        ],
      ),
    );
  }

  void _exportDB() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    DatabaseHelper.instance.queryAllRows().then((value) async {
      final String val = value.toString();

      // Comparte el archivo
      final shareResult = await Share.shareXFiles([
        XFile.fromData(
          Uint8List.fromList(val.codeUnits),
          name: 'my_data.txt',
          mimeType: 'application/json',
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
