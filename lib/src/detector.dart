import 'dart:typed_data';

import 'package:exif/exif.dart';

import 'gr_models.dart';
import 'models.dart';

/// GR filename pattern: R + digit + 6 digits + extension.
final _grFilenamePattern = RegExp(
  r'^R\d{7}\.(jpe?g|dng|raf|tif{1,2})$',
  caseSensitive: false,
);

/// Detects whether an image was taken with a Ricoh GR camera.
///
/// Supports detection via:
/// - EXIF metadata (definitive identification)
/// - Filename patterns (estimated, less reliable)
///
/// This package is pure Dart with no `dart:io` dependency,
/// so it works on all platforms including web.
///
/// ```dart
/// final detector = GrCameraDetector();
///
/// // From image bytes (all platforms)
/// final result = await detector.detectFromBytes(imageBytes);
/// print(result.isGrCamera); // true
/// print(result.model);      // GrCameraModel.grIV
///
/// // From filename only
/// final result2 = detector.detectFromFilename('R0001234.JPG');
/// print(result2.isConfirmed); // false (filename-based)
/// ```
class GrCameraDetector {
  /// Creates a new [GrCameraDetector].
  const GrCameraDetector();

  /// Detects a GR camera from raw image bytes.
  ///
  /// Reads the EXIF metadata from [imageBytes] and checks for GR camera
  /// identification. Also checks the optional [filename] for pattern matching.
  ///
  /// Returns a [GrDetectionResult] with the detection details.
  Future<GrDetectionResult> detectFromBytes(
    Uint8List imageBytes, {
    String? filename,
  }) async {
    try {
      final exifData = await readExifFromBytes(imageBytes);
      if (exifData.isEmpty) {
        // No EXIF data; fall back to filename if provided
        if (filename != null) {
          return detectFromFilename(filename);
        }
        return const GrDetectionResult.notDetected();
      }

      final exifResult = detectFromExifTags(exifData);

      // If filename is also provided, check for combined result
      if (filename != null && exifResult.isGrCamera) {
        final filenameResult = detectFromFilename(filename);
        if (filenameResult.isGrCamera) {
          return GrDetectionResult(
            isGrCamera: true,
            model: exifResult.model,
            method: DetectionMethod.both,
            exifMake: exifResult.exifMake,
            exifModel: exifResult.exifModel,
          );
        }
      }

      if (exifResult.isGrCamera) {
        return exifResult;
      }

      // EXIF didn't match; try filename
      if (filename != null) {
        return detectFromFilename(filename);
      }

      return const GrDetectionResult.notDetected();
    } on Exception catch (_) {
      // If EXIF parsing fails, fall back to filename
      if (filename != null) {
        return detectFromFilename(filename);
      }
      return const GrDetectionResult.notDetected();
    }
  }

  /// Detects a GR camera from already-parsed EXIF tags.
  ///
  /// Use this if you have already parsed EXIF data with the `exif` package.
  GrDetectionResult detectFromExifTags(Map<String, IfdTag> exifData) {
    final makeTag = exifData['Image Make'];
    final modelTag = exifData['Image Model'];

    final make = makeTag?.printable.trim();
    final model = modelTag?.printable.trim();

    if (make == null || model == null) {
      return const GrDetectionResult.notDetected();
    }

    // Check if Make is from Ricoh
    if (!ricohMakeValues.contains(make)) {
      return const GrDetectionResult.notDetected();
    }

    // Try exact model match first
    final grModel = grModelMapping[model];
    if (grModel != null) {
      return GrDetectionResult(
        isGrCamera: true,
        model: grModel,
        method: DetectionMethod.exif,
        exifMake: make,
        exifModel: model,
      );
    }

    // Try case-insensitive partial match for unknown GR models
    final modelUpper = model.toUpperCase();
    if (modelUpper.contains('GR')) {
      return GrDetectionResult(
        isGrCamera: true,
        model: GrCameraModel.unknown,
        method: DetectionMethod.exif,
        exifMake: make,
        exifModel: model,
      );
    }

    return const GrDetectionResult.notDetected();
  }

  /// Detects a GR camera from a filename.
  ///
  /// GR cameras typically use filenames like `R0001234.JPG`, `R0001234.DNG`.
  /// The prefix is user-configurable on the camera (R0, R1, R2, etc.).
  ///
  /// **Note:** This detection method is not definitive. Other cameras may use
  /// similar naming conventions. Check [GrDetectionResult.isConfirmed] to
  /// determine reliability.
  GrDetectionResult detectFromFilename(String filename) {
    // Extract just the filename if a path is provided
    final name = filename.split('/').last.split('\\').last;

    if (_grFilenamePattern.hasMatch(name)) {
      return const GrDetectionResult(
        isGrCamera: true,
        model: null, // Cannot determine model from filename alone
        method: DetectionMethod.filename,
      );
    }

    return const GrDetectionResult.notDetected();
  }
}
