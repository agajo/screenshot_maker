import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' show TestWindow;

void runCustomApp(Widget app) {
  final _binding = WidgetsFlutterBindingWrapper.ensureInitialized();
  _binding
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}

class WidgetsFlutterBindingWrapper extends WidgetsFlutterBinding {
  WidgetsFlutterBindingWrapper._();
  factory WidgetsFlutterBindingWrapper.ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      WidgetsFlutterBindingWrapper._();
    }
    return WidgetsBinding.instance! as WidgetsFlutterBindingWrapper;
  }

  @override
  void scheduleAttachRootWidget(Widget rootWidget) {
    Timer.run(() {
      attachRootWidget(rootWidget);
    });
  }

  TestWindow? _customWindow;

  @override
  TestWindow get window {
    return _customWindow ??= TestWindow(window: ui.window);
  }
}
