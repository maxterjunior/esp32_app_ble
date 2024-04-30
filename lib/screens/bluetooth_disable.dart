import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 150.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth desactivado',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
