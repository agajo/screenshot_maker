# screenshot_maker

A package for generating images laid out using Flutter. This package allows you to use Flutter's amazing layout system to generate images. You can use it to create screenshots for the App Store and Play Store.


![out2のコピー](https://user-images.githubusercontent.com/12369062/97675378-8e6e9c00-1ad2-11eb-8504-fcbb378326c1.png)

You can use Flutter Inspector and Debug Paint to debug the layout.

![out2 2](https://user-images.githubusercontent.com/12369062/97772099-09918a00-1b87-11eb-922e-b9be8735be5b.png)

This package provides two widgets: ScreenshotMaker and Simulated.


## Usage

### ScreenshotMaker

Renders the child according to the specified size and writes it to the specified file.

Passing this widget to runApp and launching it as a Flutter app with a simulator will output the image.
The simulator you use is independent of the output size.
In order to easily adjust the layout, I recommend using a tablet device with a large display such as an iPad.

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot_maker/screenshot_maker.dart';

void main() {
  runApp(
    ScreenshotMaker(
      // TODO: write your absolute path.
      outputFile: File('/Users/your_name/Desktop/simple.png'),
      size: Size(500, 1000),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          body: Text('text'),
        ),
      ),
    ),
  );
}
```

### Simulated

Fit your Flutter app into the device frame image you specify and compose it.
Position and size are specified by innerScreenOffset and innerScreenSize.

The device frame image must have a transparent display area.
There are no device frame images included in this package, so you'll need to prepare them.
There is a very simple one in example/assets, but I don't recommend using it in production.

```dart
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
```