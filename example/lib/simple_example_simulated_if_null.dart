import 'package:flutter/material.dart';
import 'package:screenshot_maker/screenshot_maker.dart';

void main() {
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Simulated(
        innerScreenSize: null,
        innerScreenOffset: null,
        originalScreenSize: null,
        deviceFrameImage: null,
        child: MyAwesomeApp(),
      ),
    ),
  );
}

class MyAwesomeApp extends StatelessWidget {
  const MyAwesomeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(appBar: AppBar(), body: Text('foobar')));
  }
}
