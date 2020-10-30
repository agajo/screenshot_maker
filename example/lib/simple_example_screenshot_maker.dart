import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot_maker/screenshot_maker.dart';

void main() {
  runApp(ScreenshotMaker(
    // TODO: write your absolute path.
    outputFile: File('/Users/your_name/Desktop/simple.png'),
    size: Size(500, 1000),
    child: MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Text('text'),
      ),
    ),
  ));
}
