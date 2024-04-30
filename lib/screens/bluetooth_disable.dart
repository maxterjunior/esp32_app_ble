import 'package:flutter/material.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({
    super.key,
  });

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
