// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'package:gr_camera_detector/gr_camera_detector.dart';

void main() async {
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
  print('');

  // Example 4: Error handling - checking for errors
  print('=== Error Handling: Checking Errors ===');
  final errorResult = await detector.detectFromBytes(
    Uint8List.fromList([0, 1, 2, 3]), // Invalid bytes
    filename: 'R0001234.JPG',
  );
  print('Is GR camera: ${errorResult.isGrCamera}');
  print('Has error: ${errorResult.hasError}');
  print('Used fallback: ${errorResult.usedFallback}');
  print('Status: ${errorResult.status}');
  if (errorResult.hasError) {
    print('Error type: ${errorResult.error.runtimeType}');
    print('Error message: ${errorResult.error}');
  }
  print('');

  // Example 5: Using DetectionStatus for detailed handling
  print('=== Detection Status Switch ===');
  final statusResult = await detector.detectFromBytes(
    Uint8List.fromList([0, 1, 2, 3]),
  );
  switch (statusResult.status) {
    case DetectionStatus.detected:
      print('GR camera detected: ${statusResult.model?.displayName}');
    case DetectionStatus.notDetected:
      print('Not a GR camera (valid image)');
    case DetectionStatus.exifError:
      print('EXIF parsing failed: ${statusResult.error}');
    case DetectionStatus.noExifData:
      print('No EXIF data in image');
    case DetectionStatus.invalidInput:
      print('Invalid input data: ${statusResult.error}');
  }
  print('');

  // Example 6: Strict mode - throws exceptions
  print('=== Strict Mode (throws exceptions) ===');
  final strictDetector = GrCameraDetector(GrDetectorConfig.strict);
  try {
    await strictDetector.detectFromBytes(Uint8List(0));
  } on InvalidImageDataException catch (e) {
    print('Caught InvalidImageDataException:');
    print('  Message: ${e.message}');
    print('  Bytes length: ${e.bytesLength}');
  } on ExifParsingException catch (e) {
    print('Caught ExifParsingException:');
    print('  Message: ${e.message}');
    print('  Cause: ${e.cause}');
    print('  Bytes preview: ${e.bytesPreview?.take(5)}...');
  } on GrDetectionException catch (e) {
    print('Caught GrDetectionException: ${e.message}');
  }
  print('');

  // Example 7: Custom error logging
  print('=== Custom Error Logging ===');
  final loggingDetector = GrCameraDetector(GrDetectorConfig(
    onError: (error) {
      print('[LOG] Error type: ${error.runtimeType}');
      print('[LOG] Error message: ${error.message}');
    },
  ));
  await loggingDetector.detectFromBytes(Uint8List.fromList([0, 1, 2, 3]));
  print('');

  // Example 8: Disable fallback
  print('=== Disable Fallback ===');
  final noFallbackDetector = GrCameraDetector(GrDetectorConfig(
    enableFallback: false,
  ));
  final noFallbackResult = await noFallbackDetector.detectFromBytes(
    Uint8List.fromList([0, 1, 2, 3]),
    filename: 'R0001234.JPG', // This won't be used as fallback
  );
  print('Is GR camera: ${noFallbackResult.isGrCamera}');
  print('Used fallback: ${noFallbackResult.usedFallback}');
  print('Has error: ${noFallbackResult.hasError}');
}
