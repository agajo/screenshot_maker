/// A package for generating images laid out using Flutter.
library screenshot_maker;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
    @required this.size,
    @required this.outputFile,
    @required this.child,
    this.completer,
    Key key,
  }) : super(key: key);

  /// Size of the image to be generated.
  final Size size;

  /// The widget to be drawn as an image.
  final Widget child;

  /// The file to be output.
  final File outputFile;

  /// A completer that is completed when the image generation is finished.
  /// By responding to this, the next image generation process can be executed.
  final Completer<void> completer;

  /// A GlobalKey to access the RenderRepaintBoundary to retrieve the image.
  static GlobalKey renderRepaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // Because it takes some time to rasterize, here is an artificial delay of 2 seconds.
      // See the following link.
      // https://api.flutter.dev/flutter/flutter_driver/FlutterDriver/screenshot.html
      await Future.delayed(Duration(seconds: 2));
      if (completer == null || (completer != null && !completer.isCompleted)) {
        final rrb = ScreenshotMaker.renderRepaintBoundaryKey.currentContext
            .findRenderObject() as RenderRepaintBoundary;
        final imgData = await rrb.toImage();
        final byteData = await imgData.toByteData(format: ImageByteFormat.png);

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
    @required Widget deviceFrameImage,
    @required Size innerScreenSize,
    @required Size innerScreenOffset,
    @required this.child,
    Size originalScreenSize,
    Key key,
  })  : deviceFrameImage = deviceFrameImage ??
            const Image(
                image: AssetImage('assets/sample_device_frame.png',
                    package: 'screenshot_maker')),
        innerScreenSize = innerScreenSize ?? const Size(1658, 3588),
        innerScreenOffset = innerScreenOffset ?? const Size(116, 103),
        originalScreenSize =
            originalScreenSize ?? (innerScreenSize ?? const Size(1658, 3588)),
        super(key: key);

  /// An Image widget to display the image of the device you want to combine.
  final Image deviceFrameImage;

  /// The size of the screen in the device image.
  final Size innerScreenSize;

  /// The offset from the top left corner to the screen in the device image.
  final Size innerScreenOffset;

  /// The number of original physical pixels of the device being used as the device image.
  /// If this is null, it will be the same as innerScreenSize.
  final Size originalScreenSize;

  /// Your app for combining with the device image.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
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
                  minWidth: originalScreenSize.width / devicePixelRatio,
                  maxWidth: originalScreenSize.width / devicePixelRatio,
                  minHeight: originalScreenSize.height / devicePixelRatio,
                  maxHeight: originalScreenSize.height / devicePixelRatio,
                ),
                child: child,
              ),
            ),
          ),
        ),
        deviceFrameImage,
      ]),
    );
  }
}
