import 'gr_models.dart';

/// Result of GR camera detection.
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

  /// Whether the detection is confirmed (EXIF-based).
  ///
  /// Returns `true` when detection is based on EXIF metadata, which provides
  /// a definitive identification. Returns `false` when detection is only
  /// based on filename patterns, which can match non-GR cameras too.
  bool get isConfirmed =>
      method == DetectionMethod.exif || method == DetectionMethod.both;

  const GrDetectionResult({
    required this.isGrCamera,
    this.model,
    required this.method,
    this.exifMake,
    this.exifModel,
  });

  /// A result indicating no GR camera was detected.
  const GrDetectionResult.notDetected()
      : isGrCamera = false,
        model = null,
        method = DetectionMethod.none,
        exifMake = null,
        exifModel = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrDetectionResult &&
          runtimeType == other.runtimeType &&
          isGrCamera == other.isGrCamera &&
          model == other.model &&
          method == other.method &&
          exifMake == other.exifMake &&
          exifModel == other.exifModel;

  @override
  int get hashCode => Object.hash(isGrCamera, model, method, exifMake, exifModel);

  @override
  String toString() => 'GrDetectionResult('
      'isGrCamera: $isGrCamera, '
      'model: ${model?.displayName ?? "none"}, '
      'method: ${method.name}, '
      'isConfirmed: $isConfirmed)';
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
