import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:led/splash.dart';
import 'package:web_socket_channel/io.dart';
import 'websocket.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebSocketLed(),
    );
  }
}
