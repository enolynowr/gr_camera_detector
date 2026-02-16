import 'dart:typed_data';

import 'package:exif/exif.dart';

import 'exceptions.dart';
import 'gr_models.dart';
import 'models.dart';

/// GR filename pattern: R + digit + 6 digits + extension.
final _grFilenamePattern = RegExp(
  r'^R\d{7}\.(jpe?g|dng|raf|tif{1,2})$',
  caseSensitive: false,
);

/// Configuration options for [GrCameraDetector].
///
/// Controls how errors are handled during detection.
///
/// ```dart
/// // Default: silent errors with fallback
/// final detector = GrCameraDetector();
///
/// // Strict: throw exceptions
/// final strictDetector = GrCameraDetector(GrDetectorConfig.strict);
///
/// // Custom: log errors
/// final loggingDetector = GrCameraDetector(GrDetectorConfig(
///   onError: (e) => logger.warning('Detection error: $e'),
/// ));
/// ```
class GrDetectorConfig {
  /// Whether to throw exceptions instead of returning error results.
  ///
  /// When `true`, [ExifParsingException] and other errors will be thrown.
  /// When `false` (default), errors are captured in [GrDetectionResult.error].
  final bool throwOnError;

  /// Whether to fall back to filename detection when EXIF parsing fails.
  ///
  /// When `true` (default), filename-based detection is attempted on EXIF errors.
  /// When `false`, errors result in immediate return without fallback.
  final bool enableFallback;

  /// Optional callback for logging/monitoring detection errors.
  ///
  /// Called whenever an error occurs during detection, regardless of
  /// [throwOnError] setting. Useful for analytics and debugging.
  final void Function(GrDetectionException error)? onError;

  /// Creates a new [GrDetectorConfig].
  const GrDetectorConfig({
    this.throwOnError = false,
    this.enableFallback = true,
    this.onError,
  });

  /// Default configuration with silent error handling and fallback enabled.
  static const GrDetectorConfig defaultConfig = GrDetectorConfig();

  /// Strict configuration that throws on any error.
  ///
  /// Useful for debugging or when you want to handle all errors explicitly.
  static const GrDetectorConfig strict = GrDetectorConfig(
    throwOnError: true,
    enableFallback: false,
  );
}

/// Detects whether an image was taken with a Ricoh GR camera.
///
/// Supports detection via:
/// - EXIF metadata (definitive identification)
/// - Filename patterns (estimated, less reliable)
///
/// This package is pure Dart with no `dart:io` dependency,
/// so it works on all platforms including web.
///
/// ## Basic Usage
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
///
/// ## Error Handling
///
/// By default, errors are captured in [GrDetectionResult.error]:
///
/// ```dart
/// final result = await detector.detectFromBytes(imageBytes);
/// if (result.hasError) {
///   print('Error occurred: ${result.error}');
/// }
/// ```
///
/// For strict mode that throws exceptions:
///
/// ```dart
/// final detector = GrCameraDetector(GrDetectorConfig.strict);
/// try {
///   final result = await detector.detectFromBytes(imageBytes);
/// } on ExifParsingException catch (e) {
///   print('EXIF parsing failed: ${e.message}');
///   print('Cause: ${e.cause}');
/// }
/// ```
class GrCameraDetector {
  /// Configuration for error handling behavior.
  final GrDetectorConfig config;

  /// Creates a new [GrCameraDetector] with the given [config].
  ///
  /// If no config is provided, uses [GrDetectorConfig.defaultConfig].
  const GrCameraDetector([this.config = GrDetectorConfig.defaultConfig]);

  /// Detects a GR camera from raw image bytes.
  ///
  /// Reads the EXIF metadata from [imageBytes] and checks for GR camera
  /// identification. Also checks the optional [filename] for pattern matching.
  ///
  /// Returns a [GrDetectionResult] with the detection details.
  ///
  /// ## Error Handling
  ///
  /// By default, errors are captured in [GrDetectionResult.error] and
  /// detection falls back to filename-based detection if available.
  ///
  /// To change this behavior, configure the detector:
  ///
  /// ```dart
  /// // Throw exceptions instead of capturing them
  /// final detector = GrCameraDetector(GrDetectorConfig.strict);
  ///
  /// // Custom error handling
  /// final detector = GrCameraDetector(GrDetectorConfig(
  ///   onError: (e) => analytics.trackError(e),
  /// ));
  /// ```
  Future<GrDetectionResult> detectFromBytes(
    Uint8List imageBytes, {
    String? filename,
  }) async {
    // Validate input
    if (imageBytes.isEmpty) {
      final error = InvalidImageDataException(
        'Image bytes cannot be empty',
        bytesLength: 0,
      );
      return _handleError(error, filename, DetectionStatus.invalidInput);
    }

    try {
      final exifData = await readExifFromBytes(imageBytes);

      if (exifData.isEmpty) {
        // No EXIF data found - this is distinct from parsing failure
        final error = NoExifDataException();
        return _handleError(error, filename, DetectionStatus.noExifData);
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
            status: DetectionStatus.detected,
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
    } on Exception catch (e, stackTrace) {
      final error = ExifParsingException(
        'Failed to parse EXIF data: $e',
        cause: e,
        stackTrace: stackTrace,
        bytesPreview: imageBytes.length > 100
            ? imageBytes.sublist(0, 100).toList()
            : imageBytes.toList(),
      );
      return _handleError(error, filename, DetectionStatus.exifError);
    }
  }

  /// Handles an error according to the configured behavior.
  GrDetectionResult _handleError(
    GrDetectionException error,
    String? filename,
    DetectionStatus status,
  ) {
    // Always call the error callback if provided
    config.onError?.call(error);

    // Throw if configured to do so
    if (config.throwOnError) {
      throw error;
    }

    // Try fallback to filename if enabled
    if (config.enableFallback && filename != null) {
      final filenameResult = detectFromFilename(filename);
      return GrDetectionResult.withFallback(
        filenameResult: filenameResult,
        originalError: error,
      );
    }

    // Return error result
    return GrDetectionResult.withError(error, status: status);
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
