import 'package:flutter/material.dart';
import 'package:screenshot_maker/screenshot_maker.dart';

void main() {
  runPkg(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Simulated(
        innerScreenSize: const Size(1658, 3588),
        innerScreenOffset: const Size(116, 103),
        originalLogicalScreenSize: const Size(414, 896),
        deviceFrameImage: Image.asset('assets/example_device_frame.png'),
        viewPadding:
            const PhysicalViewPadding(left: 0, top: 68, right: 0, bottom: 66),
        child: const MyAwesomeApp(),
      ),
    ),
  );
}

class MyAwesomeApp extends StatelessWidget {
  const MyAwesomeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: Text("My Awesome App")),
            body: ElevatedButton(child: Text('foobar'), onPressed: () {})));
  }
}
