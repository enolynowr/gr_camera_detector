# gr_camera_detector

A Dart package that detects whether a photo was taken with a Ricoh GR series camera.

It identifies GR cameras by analyzing EXIF metadata and filename patterns. Since it does
not use `dart:io`, it works on **all platforms including web, mobile, and desktop**.

## Features

- 📷 **EXIF-based detection** — Reliable identification via Make/Model metadata
- 📄 **Filename pattern detection** — Matches GR-specific filename patterns (`R0######.JPG`)
- 🌐 **Multi-platform** — No `dart:io` dependency, supports all platforms including web
- ✅ **All models supported** — From GR DIGITAL to GR IV Monochrome

### Supported Models

| Series     | Models                                   |
| ---------- | ---------------------------------------- |
| GR DIGITAL | GR DIGITAL, II, III, IV                  |
| GR         | GR, GR II                                |
| GR III     | GR III, GR IIIx, GR III HDF, GR IIIx HDF |
| GR IV      | GR IV, GR IV HDF, GR IV Monochrome       |

## Getting started

```yaml
dependencies:
    gr_camera_detector: ^0.1.0
```

## Usage

### Detect from image bytes (all platforms)

```dart
import 'dart:typed_data';
import 'package:gr_camera_detector/gr_camera_detector.dart';

final detector = GrCameraDetector();

// Read EXIF from image bytes to detect GR camera
final Uint8List imageBytes = ...; // Image byte data
final result = await detector.detectFromBytes(imageBytes);

if (result.isGrCamera) {
  print('GR camera photo! Model: ${result.model?.displayName}');
  print('Confirmed: ${result.isConfirmed}');
}
```

### Detect from filename

```dart
final result = detector.detectFromFilename('R0001234.JPG');

if (result.isGrCamera) {
  // Filename-based detection is an estimate, so isConfirmed == false
  print('Likely a GR camera photo (filename-based)');
}
```

### Combined detection (bytes + filename)

```dart
final result = await detector.detectFromBytes(
  imageBytes,
  filename: 'R0001234.JPG',
);

// When both EXIF and filename match, method == DetectionMethod.both
if (result.method == DetectionMethod.both) {
  print('Both EXIF and filename confirmed');
}
```

### Model information

```dart
final model = result.model;
if (model != null) {
  print('Model: ${model.displayName}');
  print('HDF filter: ${model.hasHdf}');
  print('Monochrome: ${model.isMonochrome}');
}
```

### Flutter web usage

```dart
import 'package:gr_camera_detector/gr_camera_detector.dart';

// Use byte data from a file picked via file picker
final bytes = await pickedFile.readAsBytes();
final result = await GrCameraDetector().detectFromBytes(
  bytes,
  filename: pickedFile.name,
);
```

## Detection Methods

| Method                     | Accuracy | `isConfirmed` | Description                    |
| -------------------------- | -------- | ------------- | ------------------------------ |
| `DetectionMethod.exif`     | High     | ✅ `true`     | EXIF metadata verified         |
| `DetectionMethod.filename` | Low      | ❌ `false`    | Filename pattern estimate      |
| `DetectionMethod.both`     | Highest  | ✅ `true`     | Both EXIF and filename matched |
| `DetectionMethod.none`     | —        | ❌ `false`    | Not detected                   |

## Additional information

- Filename detection is for reference only, as other cameras may use similar patterns.
- This package will be updated when new GR models are released.
- For bug reports or feature requests, please visit
  [GitHub Issues](https://github.com/enolynowr/gr_camera_detector/issues).
