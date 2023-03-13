import 'package:flutter/material.dart';

class pinout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: InteractiveViewer(
          panEnabled: false, // Set it to false
          boundaryMargin: EdgeInsets.all(10),
          minScale: 0.5,
          maxScale: 3,
          child: Image.asset(
            'assets/images/pinout.png',
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
