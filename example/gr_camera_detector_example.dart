// ignore_for_file: avoid_print
import 'package:gr_camera_detector/gr_camera_detector.dart';

void main() {
  final detector = GrCameraDetector();

  // Example 1: Detect from filename
  print('=== Filename Detection ===');
  final filenameResult = detector.detectFromFilename('R0001234.JPG');
  print('Is GR camera: ${filenameResult.isGrCamera}');
  print('Method: ${filenameResult.method}');
  print('Confirmed: ${filenameResult.isConfirmed}');
  print('');

  // Example 2: Non-GR filename
  print('=== Non-GR Filename ===');
  final nonGrResult = detector.detectFromFilename('IMG_1234.JPG');
  print('Is GR camera: ${nonGrResult.isGrCamera}');
  print('');

  // Example 3: Detect from EXIF tags (simulated)
  // In a real app, you would get EXIF data from image bytes:
  //
  //   import 'dart:typed_data';
  //   final imageBytes = Uint8List.fromList([...]); // your image bytes
  //   final result = await detector.detectFromBytes(imageBytes);
  //
  // Or with a filename for combined detection:
  //
  //   final result = await detector.detectFromBytes(
  //     imageBytes,
  //     filename: 'R0001234.JPG',
  //   );

  print('=== GrCameraModel Info ===');
  for (final model in GrCameraModel.values) {
    if (model == GrCameraModel.unknown) continue;
    print(
      '${model.displayName}'
      '${model.hasHdf ? " (HDF)" : ""}'
      '${model.isMonochrome ? " (Mono)" : ""}',
    );
  }
}
