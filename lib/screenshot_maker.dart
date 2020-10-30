library screenshot_maker;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ScreenshotMaker extends StatelessWidget {
  const ScreenshotMaker(
      {@required this.size,
      @required this.outputFile,
      @required this.child,
      this.completer});
  final Size size;
  final Widget child;
  final File outputFile;
  final Completer<void> completer;
  static GlobalKey renderRepaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // Because it takes some time to rasterize, here is an artificial delay of 2 seconds.
      // See the following link.
      // https://api.flutter.dev/flutter/flutter_driver/FlutterDriver/screenshot.html
      await Future.delayed(Duration(seconds: 2));
      final rrb = ScreenshotMaker.renderRepaintBoundaryKey.currentContext
          .findRenderObject() as RenderRepaintBoundary;
      final imgData = await rrb.toImage();
      final byteData = await imgData.toByteData(format: ImageByteFormat.png);

      final pngBytes = byteData.buffer.asUint8List();
      outputFile.writeAsBytesSync(pngBytes);
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
    });

    // Thanks to this FittedBox, you can use Debug Paint on a simulator.
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

class Simulated extends StatelessWidget {
  const Simulated({
    @required this.deviceFrameImage,
    @required this.innerScreenSize,
    @required this.innerScreenOffset,
    @required this.child,
    Size originalScreenSize,
  }) : originalScreenSize = originalScreenSize ?? innerScreenSize;
  final Image deviceFrameImage;
  final Size innerScreenSize;
  final Size innerScreenOffset;
  final Size originalScreenSize;
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
