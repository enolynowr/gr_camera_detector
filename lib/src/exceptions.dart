/// Custom exceptions for GR camera detection errors.
///
/// This module provides a hierarchy of exceptions that allow developers
/// to distinguish between different failure modes during detection.
library;

/// Base exception for GR camera detection errors.
///
/// This is the parent class for all detection-related exceptions.
/// Catch this type to handle any detection error generically.
///
/// ```dart
/// try {
///   final result = await detector.detectFromBytes(bytes);
/// } on GrDetectionException catch (e) {
///   print('Detection failed: ${e.message}');
///   if (e.cause != null) {
///     print('Caused by: ${e.cause}');
///   }
/// }
/// ```
sealed class GrDetectionException implements Exception {
  /// Human-readable description of what went wrong.
  final String message;

  /// The original exception that caused this error, if any.
  final Object? cause;

  /// Stack trace from the original error, if available.
  final StackTrace? stackTrace;

  const GrDetectionException(
    this.message, {
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception thrown when EXIF data parsing fails.
///
/// This can occur when:
/// - The image bytes are corrupted or truncated
/// - The image format is not supported
/// - The EXIF data structure is malformed
///
/// ```dart
/// try {
///   final result = await detector.detectFromBytes(corruptedBytes);
/// } on ExifParsingException catch (e) {
///   print('EXIF parsing failed: ${e.message}');
///   print('Original error: ${e.cause}');
///   print('Bytes preview: ${e.bytesPreview}');
/// }
/// ```
final class ExifParsingException extends GrDetectionException {
  /// Preview of the raw bytes that failed to parse (first 100 bytes).
  ///
  /// Useful for debugging to identify the image format or corruption.
  final List<int>? bytesPreview;

  const ExifParsingException(
    super.message, {
    super.cause,
    super.stackTrace,
    this.bytesPreview,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ExifParsingException: $message');
    if (bytesPreview != null && bytesPreview!.isNotEmpty) {
      final preview = bytesPreview!.take(10).map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ');
      buffer.write(' (bytes: $preview...)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when image bytes are invalid or empty.
///
/// This indicates the input data itself is problematic, not the parsing.
/// Check if the file was read correctly or if the data was truncated.
///
/// ```dart
/// try {
///   final result = await detector.detectFromBytes(Uint8List(0));
/// } on InvalidImageDataException catch (e) {
///   print('Invalid data: ${e.message}');
///   print('Bytes length: ${e.bytesLength}');
/// }
/// ```
final class InvalidImageDataException extends GrDetectionException {
  /// The length of the provided bytes.
  final int bytesLength;

  const InvalidImageDataException(
    super.message, {
    super.cause,
    super.stackTrace,
    required this.bytesLength,
  });

  @override
  String toString() => 'InvalidImageDataException: $message (bytesLength: $bytesLength)';
}

/// Exception thrown when no EXIF data is found in a valid image.
///
/// This is distinct from [ExifParsingException] - the image is valid
/// but simply lacks EXIF metadata. This can happen with:
/// - Screenshots
/// - Images that have been stripped of metadata
/// - Some image formats that don't support EXIF
///
/// ```dart
/// final result = await detector.detectFromBytes(screenshotBytes);
/// if (result.error is NoExifDataException) {
///   print('Image has no EXIF data - trying filename detection');
/// }
/// ```
final class NoExifDataException extends GrDetectionException {
  const NoExifDataException([
    super.message = 'No EXIF metadata found in image',
  ]);

  @override
  String toString() => 'NoExifDataException: $message';
}
