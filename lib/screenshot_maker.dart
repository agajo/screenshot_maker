/// A package for generating images laid out using Flutter.
library screenshot_maker;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' show TestWindow;

/// A widget for generating images.
/// When you pass a widget as a child and let it work in the simulator, it generates an image.
///
/// ```dart
/// import 'dart:io';
/// import 'package:flutter/material.dart';
/// import 'package:screenshot_maker/screenshot_maker.dart';
///
/// void main() {
///   runApp(
///     ScreenshotMaker(
///       // write your absolute path.
///       outputFile: File('/Users/your_name/Desktop/simple.png'),
///       size: Size(500, 1000),
///       child: MaterialApp(
///         home: Scaffold(
///           appBar: AppBar(),
///           body: Text('text'),
///         ),
///       ),
///     ),
///   );
/// }
/// ```
class ScreenshotMaker extends StatelessWidget {
  const ScreenshotMaker({
    required this.size,
    required this.outputFile,
    required this.child,
    this.completer,
    Key? key,
  }) : super(key: key);

  /// Size of the image to be generated.
  final Size size;

  /// The widget to be drawn as an image.
  final Widget child;

  /// The file to be output.
  final File outputFile;

  /// A completer that is completed when the image generation is finished.
  /// By responding to this, the next image generation process can be executed.
  final Completer<void>? completer;

  /// A GlobalKey to access the RenderRepaintBoundary to retrieve the image.
  static GlobalKey renderRepaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      // Because it takes some time to rasterize, here is an artificial delay of 2 seconds.
      // See the following link.
      // https://api.flutter.dev/flutter/flutter_driver/FlutterDriver/screenshot.html
      await Future.delayed(Duration(seconds: 2));
      if (completer == null || (completer != null && !completer!.isCompleted)) {
        final rrb = ScreenshotMaker.renderRepaintBoundaryKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        final imgData = await rrb.toImage();
        final byteData = await (imgData.toByteData(
            format: ui.ImageByteFormat.png) as FutureOr<ByteData>);

        final pngBytes = byteData.buffer.asUint8List();
        outputFile.writeAsBytesSync(pngBytes);
        completer?.complete();
      }
    });

    // Thanks to this FittedBox, you can use Flutter Inspector and Debug Paint on a simulator.
    return FittedBox(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width,
          minWidth: size.width,
          maxHeight: size.height,
          minHeight: size.height,
        ),
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: RepaintBoundary(
            key: ScreenshotMaker.renderRepaintBoundaryKey,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A widget for fitting your app into a device frame image.
/// If all arguments except child are set to null, the sample device frame image will be used.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:screenshot_maker/screenshot_maker.dart';
///
/// void main() {
///   runApp(
///     Directionality(
///       textDirection: TextDirection.ltr,
///       child: Simulated(
///         innerScreenSize: Size(1658, 3588),
///         innerScreenOffset: Size(116, 103),
///         originalScreenSize: Size(1242, 2688),
///         deviceFrameImage: Image.asset('assets/example_device_frame.png'),
///         child: MyAwesomeApp(),
///       ),
///     ),
///   );
/// }
///
/// class MyAwesomeApp extends StatelessWidget {
///   const MyAwesomeApp();
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(home: Scaffold(appBar: AppBar(), body: Text('foobar')));
///   }
/// }
/// ```
class Simulated extends StatelessWidget {
  const Simulated({
    required this.deviceFrameImage,
    required this.innerScreenSize,
    required this.innerScreenOffset,
    required this.viewPadding,
    required this.originalLogicalScreenSize,
    this.locale,
    required this.child,
    Key? key,
  }) : super(key: key);

  /// By using this constructor, you can use a very simple sample device frame image.
  /// It is not recommended to use this for the actual screenshots for the store.
  const Simulated.sample({required this.child, this.locale, Key? key})
      : deviceFrameImage = const Image(
            image: AssetImage('assets/sample_device_frame.png',
                package: 'screenshot_maker')),
        innerScreenSize = const Size(1658, 3588),
        innerScreenOffset = const Size(116, 103),
        originalLogicalScreenSize = const Size(414, 896),
        viewPadding =
            const PhysicalViewPadding(left: 0, top: 68, right: 0, bottom: 66),
        super(key: key);

  /// An Image widget to display the image of the device you want to combine.
  final Image deviceFrameImage;

  /// The size of the screen in the device image.
  final Size innerScreenSize;

  /// The offset from the top left corner to the screen in the device image.
  final Size innerScreenOffset;

  /// The number of original LOGICAL pixels of the device being used as the device image.
  final Size originalLogicalScreenSize;

  /// The part of the display that is partially hidden by the system UI.
  /// This allows you to represent parts of the display that are hidden by the hardware display "notch" or the system status bar.
  final PhysicalViewPadding viewPadding;

  final Locale? locale;

  /// Your app for combining with the device image.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!(WidgetsBinding.instance!.window is TestWindow)) {
      throw StateError(
          'When you use Simulated, you need to use runPkg instead of runApp.');
    }
    final testWindow = WidgetsBinding.instance!.window as TestWindow;
    testWindow.devicePixelRatioTestValue =
        innerScreenSize.height / originalLogicalScreenSize.height;
    testWindow.viewPaddingTestValue = viewPadding;
    testWindow.paddingTestValue = viewPadding;
    testWindow.localeTestValue = locale ?? testWindow.locale;

    return FittedBox(
      child: Stack(children: [
        Padding(
          padding: EdgeInsets.only(
            left: innerScreenOffset.width,
            top: innerScreenOffset.height,
          ),
          child: SizedBox(
            width: innerScreenSize.width,
            height: innerScreenSize.height,
            child: FittedBox(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: originalLogicalScreenSize.width,
                  maxWidth: originalLogicalScreenSize.width,
                  minHeight: originalLogicalScreenSize.height,
                  maxHeight: originalLogicalScreenSize.height,
                ),
                child: child,
              ),
            ),
          ),
        ),
        IgnorePointer(child: deviceFrameImage),
      ]),
    );
  }
}

class PhysicalViewPadding implements ui.WindowPadding {
  const PhysicalViewPadding(
      {required this.left,
      required this.top,
      required this.right,
      required this.bottom});
  @override
  final double left;
  @override
  final double top;
  @override
  final double right;
  @override
  final double bottom;
}

void runPkg(Widget app) {
  final _binding = _WidgetsFlutterBindingWithTestWindow.ensureInitialized();
  _binding
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}

class _WidgetsFlutterBindingWithTestWindow extends WidgetsFlutterBinding {
  _WidgetsFlutterBindingWithTestWindow._();
  factory _WidgetsFlutterBindingWithTestWindow.ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      _WidgetsFlutterBindingWithTestWindow._();
    }
    return WidgetsBinding.instance! as _WidgetsFlutterBindingWithTestWindow;
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
