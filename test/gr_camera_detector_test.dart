import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:gr_camera_detector/gr_camera_detector.dart';
import 'package:test/test.dart';

void main() {
  late GrCameraDetector detector;

  setUp(() {
    detector = const GrCameraDetector();
  });

  group('detectFromExifTags', () {
    test('detects RICOH GR IV from EXIF', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH GR IV');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.grIV);
      expect(result.method, DetectionMethod.exif);
      expect(result.isConfirmed, isTrue);
      expect(result.exifMake, 'RICOH');
      expect(result.exifModel, 'RICOH GR IV');
    });

    test('detects RICOH GR IV HDF from EXIF', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH GR IV HDF');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.grIVHdf);
      expect(result.model!.hasHdf, isTrue);
    });

    test('detects RICOH GR IV Monochrome from EXIF', () {
      final exifData = _makeExifData(
        make: 'RICOH',
        model: 'RICOH GR IV Monochrome',
      );
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.grIVMono);
      expect(result.model!.isMonochrome, isTrue);
    });

    test('detects RICOH GR III from EXIF', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH GR III');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.grIII);
    });

    test('detects RICOH GR IIIx from EXIF', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH GR IIIx');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.grIIIx);
    });

    test('detects RICOH GR III HDF from EXIF', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH GR III HDF');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.grIIIHdf);
      expect(result.model!.hasHdf, isTrue);
    });

    test('detects RICOH GR IIIx HDF from EXIF', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH GR IIIx HDF');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.grIIIxHdf);
      expect(result.model!.hasHdf, isTrue);
    });

    test('detects RICOH GR (2013) from EXIF', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH GR');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.gr);
    });

    test('detects RICOH GR II from EXIF', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH GR II');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.grII);
    });

    test('detects GR DIGITAL series from EXIF', () {
      for (final entry in {
        'RICOH GR DIGITAL': GrCameraModel.grDigital,
        'RICOH GR DIGITAL II': GrCameraModel.grDigitalII,
        'RICOH GR DIGITAL III': GrCameraModel.grDigitalIII,
        'RICOH GR DIGITAL IV': GrCameraModel.grDigitalIV,
        'Ricoh GR Digital IV': GrCameraModel.grDigitalIV,
      }.entries) {
        final exifData = _makeExifData(make: 'RICOH', model: entry.key);
        final result = detector.detectFromExifTags(exifData);

        expect(result.isGrCamera, isTrue, reason: 'Failed for ${entry.key}');
        expect(result.model, entry.value, reason: 'Failed for ${entry.key}');
      }
    });

    test('detects unknown GR model from EXIF when Make is RICOH', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH GR V Future');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.unknown);
    });

    test('does not detect non-Ricoh camera', () {
      final exifData = _makeExifData(make: 'Canon', model: 'Canon EOS R5');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isFalse);
      expect(result.model, isNull);
      expect(result.method, DetectionMethod.none);
    });

    test('does not detect non-GR Ricoh camera', () {
      final exifData = _makeExifData(make: 'RICOH', model: 'RICOH THETA Z1');
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isFalse);
    });

    test('handles Ricoh with alternate Make value', () {
      final exifData = _makeExifData(
        make: 'RICOH IMAGING COMPANY, LTD.',
        model: 'RICOH GR III',
      );
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isTrue);
      expect(result.model, GrCameraModel.grIII);
    });

    test('handles empty EXIF data', () {
      final result = detector.detectFromExifTags({});

      expect(result.isGrCamera, isFalse);
      expect(result.method, DetectionMethod.none);
    });
  });

  group('detectFromFilename', () {
    test('detects GR filename pattern R0######.JPG', () {
      final result = detector.detectFromFilename('R0001234.JPG');

      expect(result.isGrCamera, isTrue);
      expect(result.method, DetectionMethod.filename);
      expect(result.isConfirmed, isFalse);
      expect(result.model, isNull);
    });

    test('detects GR filename pattern with lowercase extension', () {
      final result = detector.detectFromFilename('R0001234.jpg');

      expect(result.isGrCamera, isTrue);
    });

    test('detects GR filename pattern with DNG extension', () {
      final result = detector.detectFromFilename('R0001234.DNG');

      expect(result.isGrCamera, isTrue);
    });

    test('detects GR filename pattern with different prefix digit', () {
      final result = detector.detectFromFilename('R1005678.JPG');

      expect(result.isGrCamera, isTrue);
    });

    test('handles filename with path', () {
      final result = detector.detectFromFilename('/photos/2025/R0001234.JPG');

      expect(result.isGrCamera, isTrue);
    });

    test('handles Windows-style path', () {
      final result = detector.detectFromFilename('C:\\Photos\\R0001234.JPG');

      expect(result.isGrCamera, isTrue);
    });

    test('does not detect non-GR filename', () {
      final result = detector.detectFromFilename('IMG_1234.JPG');

      expect(result.isGrCamera, isFalse);
    });

    test('does not detect filename with wrong prefix', () {
      final result = detector.detectFromFilename('S0001234.JPG');

      expect(result.isGrCamera, isFalse);
    });

    test('does not detect filename with wrong digit count', () {
      final result = detector.detectFromFilename('R012345.JPG');

      expect(result.isGrCamera, isFalse);
    });

    test('detects GR filename pattern with RAF extension', () {
      final result = detector.detectFromFilename('R0001234.RAF');

      expect(result.isGrCamera, isTrue);
    });

    test('detects GR filename pattern with TIF extension', () {
      final result = detector.detectFromFilename('R0001234.TIF');

      expect(result.isGrCamera, isTrue);
    });

    test('detects GR filename pattern with TIFF extension', () {
      final result = detector.detectFromFilename('R0001234.TIFF');

      expect(result.isGrCamera, isTrue);
    });

    test('detects GR filename pattern with JPEG extension', () {
      final result = detector.detectFromFilename('R0001234.JPEG');

      expect(result.isGrCamera, isTrue);
    });

    test('handles empty filename', () {
      final result = detector.detectFromFilename('');

      expect(result.isGrCamera, isFalse);
      expect(result.method, DetectionMethod.none);
    });
  });

  group('GrCameraModel', () {
    test('displayName returns correct names', () {
      expect(GrCameraModel.grIV.displayName, 'GR IV');
      expect(GrCameraModel.grIVHdf.displayName, 'GR IV HDF');
      expect(GrCameraModel.grIVMono.displayName, 'GR IV Monochrome');
      expect(GrCameraModel.grIII.displayName, 'GR III');
      expect(GrCameraModel.grDigital.displayName, 'GR DIGITAL');
    });

    test('hasHdf returns true only for HDF models', () {
      expect(GrCameraModel.grIIIHdf.hasHdf, isTrue);
      expect(GrCameraModel.grIIIxHdf.hasHdf, isTrue);
      expect(GrCameraModel.grIVHdf.hasHdf, isTrue);
      expect(GrCameraModel.grIV.hasHdf, isFalse);
      expect(GrCameraModel.grIII.hasHdf, isFalse);
    });

    test('isMonochrome returns true only for Monochrome model', () {
      expect(GrCameraModel.grIVMono.isMonochrome, isTrue);
      expect(GrCameraModel.grIV.isMonochrome, isFalse);
      expect(GrCameraModel.grIVHdf.isMonochrome, isFalse);
    });
  });

  group('GrDetectionResult', () {
    test('isConfirmed is true for EXIF detection', () {
      const result = GrDetectionResult(
        isGrCamera: true,
        model: GrCameraModel.grIV,
        method: DetectionMethod.exif,
      );
      expect(result.isConfirmed, isTrue);
    });

    test('isConfirmed is true for both detection', () {
      const result = GrDetectionResult(
        isGrCamera: true,
        model: GrCameraModel.grIV,
        method: DetectionMethod.both,
      );
      expect(result.isConfirmed, isTrue);
    });

    test('isConfirmed is false for filename detection', () {
      const result = GrDetectionResult(
        isGrCamera: true,
        method: DetectionMethod.filename,
      );
      expect(result.isConfirmed, isFalse);
    });

    test('toString produces readable output', () {
      const result = GrDetectionResult(
        isGrCamera: true,
        model: GrCameraModel.grIV,
        method: DetectionMethod.exif,
      );
      expect(result.toString(), contains('GR IV'));
      expect(result.toString(), contains('isConfirmed: true'));
    });

    test('notDetected factory produces correct result', () {
      const result = GrDetectionResult.notDetected();
      expect(result.isGrCamera, isFalse);
      expect(result.model, isNull);
      expect(result.method, DetectionMethod.none);
      expect(result.isConfirmed, isFalse);
    });

    test('equality works for identical results', () {
      const a = GrDetectionResult(
        isGrCamera: true,
        model: GrCameraModel.grIV,
        method: DetectionMethod.exif,
        exifMake: 'RICOH',
        exifModel: 'RICOH GR IV',
      );
      const b = GrDetectionResult(
        isGrCamera: true,
        model: GrCameraModel.grIV,
        method: DetectionMethod.exif,
        exifMake: 'RICOH',
        exifModel: 'RICOH GR IV',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality fails for different results', () {
      const a = GrDetectionResult(
        isGrCamera: true,
        model: GrCameraModel.grIV,
        method: DetectionMethod.exif,
      );
      const b = GrDetectionResult(
        isGrCamera: true,
        model: GrCameraModel.grIII,
        method: DetectionMethod.exif,
      );
      expect(a, isNot(equals(b)));
    });

    test('notDetected results are equal', () {
      const a = GrDetectionResult.notDetected();
      const b = GrDetectionResult.notDetected();
      expect(a, equals(b));
    });
  });

  group('detectFromBytes', () {
    test('returns notDetected for empty bytes', () async {
      final result = await detector.detectFromBytes(Uint8List(0));

      expect(result.isGrCamera, isFalse);
      expect(result.method, DetectionMethod.none);
    });

    test('returns notDetected for invalid bytes', () async {
      final result = await detector.detectFromBytes(
        Uint8List.fromList([0, 1, 2, 3, 4, 5]),
      );

      expect(result.isGrCamera, isFalse);
    });

    test('falls back to filename for invalid bytes with filename', () async {
      final result = await detector.detectFromBytes(
        Uint8List.fromList([0, 1, 2, 3]),
        filename: 'R0001234.JPG',
      );

      expect(result.isGrCamera, isTrue);
      expect(result.method, DetectionMethod.filename);
    });

    test('returns notDetected for invalid bytes without filename', () async {
      final result = await detector.detectFromBytes(
        Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
      );

      expect(result.isGrCamera, isFalse);
    });
  });

  group('detectFromExifTags - model mapping without RICOH prefix', () {
    test('detects GR models without RICOH prefix', () {
      for (final entry in {
        'GR': GrCameraModel.gr,
        'GR II': GrCameraModel.grII,
        'GR III': GrCameraModel.grIII,
        'GR IIIx': GrCameraModel.grIIIx,
        'GR III HDF': GrCameraModel.grIIIHdf,
        'GR IIIx HDF': GrCameraModel.grIIIxHdf,
        'GR IV': GrCameraModel.grIV,
        'GR IV HDF': GrCameraModel.grIVHdf,
        'GR IV Monochrome': GrCameraModel.grIVMono,
      }.entries) {
        final exifData = _makeExifData(make: 'RICOH', model: entry.key);
        final result = detector.detectFromExifTags(exifData);

        expect(result.isGrCamera, isTrue,
            reason: 'Failed for ${entry.key}');
        expect(result.model, entry.value,
            reason: 'Wrong model for ${entry.key}');
      }
    });

    test('handles EXIF with Make but no Model', () {
      final exifData = <String, IfdTag>{
        'Image Make': IfdTag(
          tag: 0x010F,
          tagType: 'ASCII',
          printable: 'RICOH',
          values: const IfdNone(),
        ),
      };
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isFalse);
    });

    test('handles EXIF with Model but no Make', () {
      final exifData = <String, IfdTag>{
        'Image Model': IfdTag(
          tag: 0x0110,
          tagType: 'ASCII',
          printable: 'RICOH GR IV',
          values: const IfdNone(),
        ),
      };
      final result = detector.detectFromExifTags(exifData);

      expect(result.isGrCamera, isFalse);
    });
  });

  group('error handling', () {
    test('returns error result for empty bytes', () async {
      final result = await detector.detectFromBytes(Uint8List(0));

      expect(result.isGrCamera, isFalse);
      expect(result.hasError, isTrue);
      expect(result.error, isA<InvalidImageDataException>());
      expect(result.status, DetectionStatus.invalidInput);
    });

    test('returns error result for invalid bytes without filename', () async {
      final result = await detector.detectFromBytes(
        Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
      );

      expect(result.isGrCamera, isFalse);
      expect(result.hasError, isTrue);
      expect(result.status, anyOf(
        DetectionStatus.exifError,
        DetectionStatus.noExifData,
      ));
    });

    test('returns fallback result with error for invalid bytes with GR filename',
        () async {
      final result = await detector.detectFromBytes(
        Uint8List.fromList([0, 1, 2, 3]),
        filename: 'R0001234.JPG',
      );

      expect(result.isGrCamera, isTrue);
      expect(result.method, DetectionMethod.filename);
      expect(result.usedFallback, isTrue);
      expect(result.hasError, isTrue);
    });

    test('returns fallback result with error for invalid bytes with non-GR filename',
        () async {
      final result = await detector.detectFromBytes(
        Uint8List.fromList([0, 1, 2, 3]),
        filename: 'IMG_1234.JPG',
      );

      expect(result.isGrCamera, isFalse);
      expect(result.usedFallback, isTrue);
      expect(result.hasError, isTrue);
      // Could be exifError or noExifData depending on how exif library handles invalid bytes
      expect(result.status, anyOf(
        DetectionStatus.exifError,
        DetectionStatus.noExifData,
      ));
    });

    test('calls onError callback when error occurs', () async {
      GrDetectionException? capturedError;
      final detectorWithCallback = GrCameraDetector(GrDetectorConfig(
        onError: (e) => capturedError = e,
      ));

      await detectorWithCallback.detectFromBytes(Uint8List.fromList([0, 1, 2]));

      expect(capturedError, isNotNull);
    });

    test('throws exception when throwOnError is true', () async {
      final strictDetector = GrCameraDetector(GrDetectorConfig.strict);

      expect(
        () => strictDetector.detectFromBytes(Uint8List(0)),
        throwsA(isA<GrDetectionException>()),
      );
    });

    test('does not use fallback when enableFallback is false', () async {
      final noFallbackDetector = GrCameraDetector(GrDetectorConfig(
        enableFallback: false,
      ));

      final result = await noFallbackDetector.detectFromBytes(
        Uint8List.fromList([0, 1, 2, 3]),
        filename: 'R0001234.JPG',
      );

      expect(result.isGrCamera, isFalse);
      expect(result.usedFallback, isFalse);
      expect(result.hasError, isTrue);
    });

    test('GrDetectionException is thrown in strict mode', () async {
      final strictDetector = GrCameraDetector(GrDetectorConfig.strict);

      try {
        await strictDetector.detectFromBytes(Uint8List.fromList([0, 1, 2, 3]));
        fail('Expected exception to be thrown');
      } on ExifParsingException catch (e) {
        // If bytes cause EXIF parsing to throw
        expect(e.message, isNotEmpty);
        expect(e.bytesPreview, isNotNull);
      } on NoExifDataException catch (e) {
        // If bytes cause EXIF to return empty (not throw)
        expect(e.message, isNotEmpty);
      }
    });

    test('ExifParsingException preserves error details', () {
      // Test the exception structure directly
      const cause = FormatException('test');
      final trace = StackTrace.current;
      final error = ExifParsingException(
        'Test error',
        cause: cause,
        stackTrace: trace,
        bytesPreview: [0xFF, 0xD8, 0xFF, 0xE0],
      );

      expect(error.message, 'Test error');
      expect(error.cause, cause);
      expect(error.stackTrace, trace);
      expect(error.bytesPreview, hasLength(4));
      expect(error.toString(), contains('ExifParsingException'));
    });

    test('InvalidImageDataException contains bytes length', () async {
      final strictDetector = GrCameraDetector(GrDetectorConfig.strict);

      try {
        await strictDetector.detectFromBytes(Uint8List(0));
        fail('Expected exception to be thrown');
      } on InvalidImageDataException catch (e) {
        expect(e.bytesLength, 0);
        expect(e.message, contains('empty'));
      }
    });
  });

  group('GrDetectionResult.withError', () {
    test('creates error result correctly', () {
      const error = NoExifDataException('Test error');
      final result = GrDetectionResult.withError(error);

      expect(result.isGrCamera, isFalse);
      expect(result.hasError, isTrue);
      expect(result.error, error);
      expect(result.status, DetectionStatus.exifError);
      expect(result.usedFallback, isFalse);
    });

    test('creates error result with custom status', () {
      const error = InvalidImageDataException('Invalid', bytesLength: 0);
      final result = GrDetectionResult.withError(
        error,
        status: DetectionStatus.invalidInput,
      );

      expect(result.status, DetectionStatus.invalidInput);
    });
  });

  group('GrDetectionResult.withFallback', () {
    test('creates fallback result for detected GR camera', () {
      const filenameResult = GrDetectionResult(
        isGrCamera: true,
        method: DetectionMethod.filename,
      );
      const error = ExifParsingException('Test error');

      final result = GrDetectionResult.withFallback(
        filenameResult: filenameResult,
        originalError: error,
      );

      expect(result.isGrCamera, isTrue);
      expect(result.method, DetectionMethod.filename);
      expect(result.usedFallback, isTrue);
      expect(result.hasError, isTrue);
      expect(result.error, error);
      expect(result.status, DetectionStatus.detected);
    });

    test('creates fallback result for non-GR camera', () {
      const filenameResult = GrDetectionResult.notDetected();
      const error = ExifParsingException('Test error');

      final result = GrDetectionResult.withFallback(
        filenameResult: filenameResult,
        originalError: error,
      );

      expect(result.isGrCamera, isFalse);
      expect(result.usedFallback, isTrue);
      expect(result.status, DetectionStatus.exifError);
    });
  });

  group('DetectionStatus', () {
    test('default status is detected for GR camera', () {
      const result = GrDetectionResult(
        isGrCamera: true,
        method: DetectionMethod.exif,
      );
      expect(result.status, DetectionStatus.detected);
    });

    test('default status is notDetected for non-GR camera', () {
      const result = GrDetectionResult(
        isGrCamera: false,
        method: DetectionMethod.none,
      );
      expect(result.status, DetectionStatus.notDetected);
    });

    test('notDetected constructor sets correct status', () {
      const result = GrDetectionResult.notDetected();
      expect(result.status, DetectionStatus.notDetected);
      expect(result.hasError, isFalse);
    });
  });

  group('GrDetectorConfig', () {
    test('defaultConfig has expected values', () {
      const config = GrDetectorConfig.defaultConfig;
      expect(config.throwOnError, isFalse);
      expect(config.enableFallback, isTrue);
      expect(config.onError, isNull);
    });

    test('strict config has expected values', () {
      const config = GrDetectorConfig.strict;
      expect(config.throwOnError, isTrue);
      expect(config.enableFallback, isFalse);
    });

    test('custom config preserves values', () {
      var callCount = 0;
      final config = GrDetectorConfig(
        throwOnError: true,
        enableFallback: false,
        onError: (_) => callCount++,
      );

      expect(config.throwOnError, isTrue);
      expect(config.enableFallback, isFalse);

      config.onError!(const NoExifDataException());
      expect(callCount, 1);
    });
  });

  group('GrDetectionResult toString with error', () {
    test('includes error in toString when present', () {
      const error = NoExifDataException('Test');
      final result = GrDetectionResult.withError(error);

      expect(result.toString(), contains('error:'));
    });

    test('includes usedFallback in toString when true', () {
      const filenameResult = GrDetectionResult(
        isGrCamera: true,
        method: DetectionMethod.filename,
      );
      const error = ExifParsingException('Test');

      final result = GrDetectionResult.withFallback(
        filenameResult: filenameResult,
        originalError: error,
      );

      expect(result.toString(), contains('usedFallback: true'));
    });
  });
}

/// Helper to create mock EXIF data for testing.
///
/// Uses [IfdTag] from the `exif` package to simulate real EXIF data.
Map<String, IfdTag> _makeExifData({
  required String make,
  required String model,
}) {
  return {
    'Image Make': IfdTag(
      tag: 0x010F,
      tagType: 'ASCII',
      printable: make,
      values: const IfdNone(),
    ),
    'Image Model': IfdTag(
      tag: 0x0110,
      tagType: 'ASCII',
      printable: model,
      values: const IfdNone(),
    ),
  };
}
