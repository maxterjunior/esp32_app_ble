import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen(this.permissions, {super.key});

  final Map<Permission, PermissionStatus> permissions;

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          widget.permissions.isEmpty
              // ? const CircularProgressIndicator()
              ? const Image(
                  image: AssetImage('assets/images/maxter.png'),
                  width: 200,
                  height: 200,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.permissions.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${entry.key}: '),
                                Icon(
                                  entry.value.isGranted
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: entry.value.isGranted
                                      ? Colors.green
                                      : Colors.red,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      )),
    );
  }
}
