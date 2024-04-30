import 'package:flutter/material.dart';

export 'gps_card.dart';
export 'next_screen.dart';
export 'ph_tile.dart';
export 'target_widget.dart';

Widget gridList(List<Widget> lista) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.all(6.0),
      child: lista[0],
    ),
  );
  // return const Text('gridList');
}
