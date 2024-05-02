import 'dart:async';

import 'package:esp32_app/screens/bluetooth_disable.dart';
import 'package:esp32_app/screens/connect_to_device.dart';
import 'package:esp32_app/screens/splash.dart';
import 'package:esp32_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:wakelock/wakelock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Wakelock.enable();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
    statusBarIconBrightness: Brightness.dark, // color icons
  ));
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  bool hasPermisions = false;
  Map<Permission, PermissionStatus> permissions = {};

  void requestPermission() async {
    await Future.delayed(const Duration(milliseconds: 500));

    permissions = await [
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
      Permission.notification,
      Permission.accessNotificationPolicy,
    ].request();

    hasPermisions = getPermisions();

    if (mounted) {
      setState(() {});
    }
  }

  bool getPermisions() {
    return permissions[Permission.bluetoothScan]!.isGranted &&
        permissions[Permission.location]!.isGranted &&
        permissions[Permission.nearbyWifiDevices]!.isGranted;
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        home: hasPermisions
            ? _adapterState == BluetoothAdapterState.on
                ? const ConnectToDevice()
                : const BluetoothOffScreen()
            : SplashScreen(permissions));
  }
}
