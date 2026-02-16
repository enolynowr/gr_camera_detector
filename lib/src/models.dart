import 'exceptions.dart';
import 'gr_models.dart';

/// The outcome status of a GR camera detection attempt.
///
/// This provides more granular information than just [GrDetectionResult.isGrCamera],
/// allowing developers to distinguish between different failure modes.
enum DetectionStatus {
  /// Successfully detected a GR camera.
  detected,

  /// Detection completed successfully, but no GR camera was found.
  ///
  /// This means the image/filename was valid, but it's not from a GR camera.
  notDetected,

  /// Detection completed, but EXIF parsing encountered an error.
  ///
  /// The result may have fallen back to filename detection.
  /// Check [GrDetectionResult.error] for details.
  exifError,

  /// Detection completed, but no EXIF data was found in the image.
  ///
  /// The result may have fallen back to filename detection.
  noExifData,

  /// Detection could not complete due to invalid input.
  ///
  /// The image bytes were empty, corrupted, or otherwise invalid.
  invalidInput,
}

/// Result of GR camera detection.
///
/// Contains information about whether a GR camera was detected, the camera
/// model, detection method, and any errors that occurred during detection.
///
/// ## Error Handling
///
/// Check [hasError] to see if any errors occurred during detection:
///
/// ```dart
/// final result = await detector.detectFromBytes(imageBytes);
/// if (result.hasError) {
///   print('Error occurred: ${result.error}');
///   print('Used fallback: ${result.usedFallback}');
/// }
/// ```
///
/// Use [status] for more granular status information:
///
/// ```dart
/// switch (result.status) {
///   case DetectionStatus.detected:
///     print('GR camera: ${result.model}');
///   case DetectionStatus.notDetected:
///     print('Not a GR camera');
///   case DetectionStatus.exifError:
///     print('EXIF parsing failed: ${result.error}');
///   case DetectionStatus.noExifData:
///     print('No EXIF data found');
///   case DetectionStatus.invalidInput:
///     print('Invalid input: ${result.error}');
/// }
/// ```
class GrDetectionResult {
  /// Whether the image was taken with a GR camera.
  final bool isGrCamera;

  /// The detected GR camera model, or `null` if not a GR camera.
  final GrCameraModel? model;

  /// How the detection was performed.
  final DetectionMethod method;

  /// The raw EXIF Make value, if available.
  final String? exifMake;

  /// The raw EXIF Model value, if available.
  final String? exifModel;

  /// The detailed status of this detection attempt.
  ///
  /// Provides more granular information than [isGrCamera] alone,
  /// allowing developers to distinguish between different failure modes.
  final DetectionStatus status;

  /// The error that occurred during detection, if any.
  ///
  /// This is non-null when [status] is [DetectionStatus.exifError],
  /// [DetectionStatus.noExifData], or [DetectionStatus.invalidInput].
  final GrDetectionException? error;

  /// Whether detection fell back to filename-based detection due to an error.
  ///
  /// When `true`, EXIF parsing failed but filename detection was attempted.
  /// Check [error] for details about what went wrong with EXIF parsing.
  final bool usedFallback;

  /// Whether an error occurred during detection.
  ///
  /// Returns `true` when [error] is non-null.
  bool get hasError => error != null;

  /// Whether the detection is confirmed (EXIF-based).
  ///
  /// Returns `true` when detection is based on EXIF metadata, which provides
  /// a definitive identification. Returns `false` when detection is only
  /// based on filename patterns, which can match non-GR cameras too.
  bool get isConfirmed =>
      method == DetectionMethod.exif || method == DetectionMethod.both;

  /// Creates a new [GrDetectionResult].
  ///
  /// For backward compatibility, [status] defaults based on [isGrCamera]:
  /// - `true` → [DetectionStatus.detected]
  /// - `false` → [DetectionStatus.notDetected]
  const GrDetectionResult({
    required this.isGrCamera,
    this.model,
    required this.method,
    this.exifMake,
    this.exifModel,
    DetectionStatus? status,
    this.error,
    this.usedFallback = false,
  }) : status = status ??
            (isGrCamera ? DetectionStatus.detected : DetectionStatus.notDetected);

  /// A result indicating no GR camera was detected.
  const GrDetectionResult.notDetected()
      : isGrCamera = false,
        model = null,
        method = DetectionMethod.none,
        exifMake = null,
        exifModel = null,
        status = DetectionStatus.notDetected,
        error = null,
        usedFallback = false;

  /// A result indicating an error occurred during detection.
  ///
  /// Use this when detection failed and no meaningful result can be provided.
  const GrDetectionResult.withError(
    this.error, {
    this.status = DetectionStatus.exifError,
  })  : isGrCamera = false,
        model = null,
        method = DetectionMethod.none,
        exifMake = null,
        exifModel = null,
        usedFallback = false;

  /// Creates a result that fell back to filename detection due to an EXIF error.
  ///
  /// [filenameResult] is the result from filename-based detection.
  /// [originalError] is the error that caused the fallback.
  factory GrDetectionResult.withFallback({
    required GrDetectionResult filenameResult,
    required GrDetectionException originalError,
  }) {
    return GrDetectionResult(
      isGrCamera: filenameResult.isGrCamera,
      model: filenameResult.model,
      method: filenameResult.method,
      exifMake: null,
      exifModel: null,
      status: filenameResult.isGrCamera
          ? DetectionStatus.detected
          : DetectionStatus.exifError,
      error: originalError,
      usedFallback: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrDetectionResult &&
          runtimeType == other.runtimeType &&
          isGrCamera == other.isGrCamera &&
          model == other.model &&
          method == other.method &&
          exifMake == other.exifMake &&
          exifModel == other.exifModel &&
          status == other.status &&
          error == other.error &&
          usedFallback == other.usedFallback;

  @override
  int get hashCode => Object.hash(
        isGrCamera,
        model,
        method,
        exifMake,
        exifModel,
        status,
        error,
        usedFallback,
      );

  @override
  String toString() {
    final buffer = StringBuffer('GrDetectionResult(')
      ..write('isGrCamera: $isGrCamera, ')
      ..write('model: ${model?.displayName ?? "none"}, ')
      ..write('method: ${method.name}, ')
      ..write('status: ${status.name}, ')
      ..write('isConfirmed: $isConfirmed');
    if (hasError) {
      buffer.write(', error: $error');
    }
    if (usedFallback) {
      buffer.write(', usedFallback: true');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// How the GR camera was detected.
enum DetectionMethod {
  /// Confirmed via EXIF metadata - definitive identification.
  exif,

  /// Estimated from filename pattern - may not be accurate.
  ///
  /// Other cameras can use similar naming conventions (e.g. R0001234.JPG).
  /// Use [GrDetectionResult.isConfirmed] to check reliability.
  filename,

  /// Both EXIF and filename matched - most reliable.
  both,

  /// No GR camera detected.
  none,
}
