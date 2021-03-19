import 'package:flutter/material.dart';
import 'package:screenshot_maker/screenshot_maker.dart';

void main() {
  runPkg(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Simulated.sample(
        child: MyAwesomeApp(),
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
        body: ElevatedButton(
          child: Text('foobar'),
          onPressed: () {},
        ),
      ),
    );
  }
}
