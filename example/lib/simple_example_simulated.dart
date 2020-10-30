import 'package:flutter/material.dart';
import 'package:screenshot_maker/screenshot_maker.dart';

void main() {
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Simulated(
        innerScreenSize: Size(1658, 3588),
        innerScreenOffset: Size(116, 103),
        originalScreenSize: Size(1242, 2688),
        deviceFrameImage: Image.asset('assets/example_device_frame.png'),
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
