import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:screenshot_maker/screenshot_maker.dart';

void main() {
  // This test doesn't work!! Please give me some hints to test this package.
  testWidgets('check red 1 dot output', (WidgetTester tester) async {
    final completer = Completer<void>();
    final outputFile = MockFile();
    await tester.pumpWidget(
        ScreenshotMaker(
          completer: completer,
          outputFile: outputFile,
          size: Size(1, 1),
          child: MaterialApp(
            home: Container(
              width: 1,
              height: 1,
              color: Color.fromARGB(255, 255, 0, 0),
            ),
          ),
        ),
        Duration(seconds: 3));
    await tester.pump(Duration(seconds: 3));
    expect(completer.future, completes);
    verify(outputFile.writeAsBytesSync(any!));
    // Skips this test because it doesn't work.
  }, skip: true);
}

class MockFile extends Mock implements File {}
