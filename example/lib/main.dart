import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:screenshot_maker/screenshot_maker.dart';

void main() {
  runApp(MakeScreenshotsContinuously());
}

class MakeScreenshotsContinuously extends StatefulWidget {
  final sizes = <Size>[
    Size(1242, 2688),
    Size(1242, 2208),
    Size(2048, 2732),
  ];
  final outputFiles = <File>[
    // TODO: write your absolute paths.
    File('/Users/your_name/Desktop/out1.png'),
    File('/Users/your_name/Desktop/out2.png'),
    File('/Users/your_name/Desktop/out3.png'),
  ];
  MakeScreenshotsContinuously({
    Key? key,
  }) : super(key: key);

  @override
  _MakeScreenshotsContinuouslyState createState() =>
      _MakeScreenshotsContinuouslyState();
}

class _MakeScreenshotsContinuouslyState
    extends State<MakeScreenshotsContinuously> {
  late int index;
  late Completer<void> completer;
  late File outputFile;
  late Size size;

  @override
  void initState() {
    super.initState();
    index = 0;
    completer = Completer();
    outputFile = widget.outputFiles[index];
    size = widget.sizes[index];
  }

  @override
  Widget build(BuildContext context) {
    completer.future.then((_) {
      if (index < widget.outputFiles.length - 1 && completer.isCompleted) {
        setState(() {
          ++index;
          completer = Completer();
          outputFile = widget.outputFiles[index];
          size = widget.sizes[index];
        });
      }
    });

    return ScreenshotMaker(
      outputFile: outputFile,
      size: size,
      completer: completer,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            // background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.purple[200]!, Colors.cyan[200]!],
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'You Can Do Everything with This App!',
                      style: TextStyle(
                          fontSize: 60,
                          color: Colors.white,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Simulated(
                    innerScreenSize: const Size(1658, 3588),
                    innerScreenOffset: const Size(116, 103),
                    originalLogicalScreenSize: const Size(414, 896),
                    viewPadding: const PhysicalViewPadding(
                        left: 0, top: 68, right: 0, bottom: 66),
                    deviceFrameImage:
                        Image.asset('assets/example_device_frame.png'),
                    child: MyAwesomeApp(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyAwesomeApp extends StatelessWidget {
  const MyAwesomeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text('My Awesome App'),
          ),
          body: Center(
              child: Text(
            'foobar',
            style: TextStyle(fontSize: 50),
          )),
        ));
  }
}
