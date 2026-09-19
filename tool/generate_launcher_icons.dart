import 'dart:io';

import 'package:image/image.dart' as img;

/// Generates Android mipmaps + iOS AppIcon PNGs from assets/images/cubex_logo.png.
void main() {
  final srcFile = File('assets/images/cubex_logo.png');
  if (!srcFile.existsSync()) {
    stderr.writeln('Missing ${srcFile.path}');
    exit(1);
  }
  final decoded = img.decodeImage(srcFile.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Could not decode logo');
    exit(1);
  }
  // Square crop/pad on cream so launcher icons stay readable.
  final square = _toSquare(decoded, background: img.ColorRgba8(255, 244, 236, 255));

  final android = <String, int>{
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };
  for (final entry in android.entries) {
    final dir = Directory('android/app/src/main/res/${entry.key}');
    dir.createSync(recursive: true);
    final out = img.copyResize(
      square,
      width: entry.value,
      height: entry.value,
      interpolation: img.Interpolation.average,
    );
    File('${dir.path}/ic_launcher.png').writeAsBytesSync(img.encodePng(out));
    stdout.writeln('Wrote ${dir.path}/ic_launcher.png (${entry.value}px)');
  }

  // Adaptive icon foreground (safe zone ~66% of 108dp → use 432px xxxhdpi-ish).
  final adaptiveDir = Directory(
    'android/app/src/main/res/mipmap-xxxhdpi',
  );
  final fg = img.copyResize(
    square,
    width: 432,
    height: 432,
    interpolation: img.Interpolation.average,
  );
  File('${adaptiveDir.path}/ic_launcher_foreground.png')
      .writeAsBytesSync(img.encodePng(fg));

  final anyDpi = Directory('android/app/src/main/res/mipmap-anydpi-v26');
  anyDpi.createSync(recursive: true);
  File('${anyDpi.path}/ic_launcher.xml').writeAsStringSync('''
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''');

  final values = Directory('android/app/src/main/res/values');
  values.createSync(recursive: true);
  File('${values.path}/colors.xml').writeAsStringSync('''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#FFF4EC</color>
</resources>
''');

  // Also place a matching foreground in each density for adaptive XML resolution.
  final fgSizes = <String, int>{
    'mipmap-mdpi': 108,
    'mipmap-hdpi': 162,
    'mipmap-xhdpi': 216,
    'mipmap-xxhdpi': 324,
    'mipmap-xxxhdpi': 432,
  };
  for (final entry in fgSizes.entries) {
    final dir = Directory('android/app/src/main/res/${entry.key}');
    final out = img.copyResize(
      square,
      width: entry.value,
      height: entry.value,
      interpolation: img.Interpolation.average,
    );
    File('${dir.path}/ic_launcher_foreground.png')
        .writeAsBytesSync(img.encodePng(out));
  }

  final ios = <String, int>{
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };
  final iosDir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
  iosDir.createSync(recursive: true);
  for (final entry in ios.entries) {
    final out = img.copyResize(
      square,
      width: entry.value,
      height: entry.value,
      interpolation: img.Interpolation.average,
    );
    File('${iosDir.path}/${entry.key}').writeAsBytesSync(img.encodePng(out));
    stdout.writeln('Wrote iOS ${entry.key}');
  }

  // Play Console hi-res icon helper
  final storeDir = Directory('store');
  storeDir.createSync(recursive: true);
  final play = img.copyResize(
    square,
    width: 512,
    height: 512,
    interpolation: img.Interpolation.average,
  );
  File('${storeDir.path}/icon_512.png').writeAsBytesSync(img.encodePng(play));
  stdout.writeln('Wrote store/icon_512.png');
  stdout.writeln('Done.');
}

img.Image _toSquare(img.Image src, {required img.ColorRgba8 background}) {
  final side = src.width > src.height ? src.width : src.height;
  final canvas = img.Image(width: side, height: side);
  img.fill(canvas, color: background);
  final dx = ((side - src.width) / 2).round();
  final dy = ((side - src.height) / 2).round();
  img.compositeImage(canvas, src, dstX: dx, dstY: dy);
  return canvas;
}
