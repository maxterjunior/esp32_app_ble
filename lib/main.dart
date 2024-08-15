import 'dart:async';
import 'dart:ui';

import 'package:esp32_app/screens/bluetooth_disable.dart';
import 'package:esp32_app/screens/connect_to_device.dart';
import 'package:esp32_app/screens/splash.dart';
import 'package:esp32_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:wakelock/wakelock.dart';

// import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
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

// this will be used as notification channel id
const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

/// Foreground and Background
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        // auto start service
        autoStart: true,
        isForegroundMode: true,

        notificationChannelId:
            notificationChannelId, // this must match with notification channel you created above.
        initialNotificationTitle: 'AWESOME SERVICE',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: notificationId,
      ));

  // const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //   notificationChannelId, // id
  //   'MY FOREGROUND SERVICE', // title
  //   description:
  //       'This channel is used for important notifications.', // description
  //   importance: Importance.low, // importance must be at low or higher level
  // );
  // if (Platform.isAndroid) {
  //   await FlutterBackgroundServiceAndroid.initialize(onStart: (data) {
  //     print('onStart');
  //     return;
  //   }, onStop: () {
  //     print('onStop');
  //     return;
  //   });
  // }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
  });
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
