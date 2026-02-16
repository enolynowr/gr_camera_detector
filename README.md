# gr_camera_detector

Ricoh GR 카메라 시리즈로 촬영한 사진인지 감지하는 Dart 패키지입니다.

EXIF 메타데이터 및 파일명 패턴을 분석하여 GR 카메라를 판별합니다. `dart:io`를
사용하지 않으므로 **웹, 모바일, 데스크톱 모든 플랫폼**에서 동작합니다.

## Features

- 📷 **EXIF 기반 감지** — Make/Model 메타데이터로 확실한 판별
- 📄 **파일명 패턴 감지** — GR 특유의 파일명 패턴(`R0######.JPG`) 매칭
- 🌐 **멀티 플랫폼** — `dart:io` 미사용, 웹 포함 전 플랫폼 지원
- ✅ **전 모델 지원** — GR DIGITAL ~ GR IV Monochrome

### 지원 모델

| 시리즈     | 모델                                     |
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

### 바이트 데이터에서 감지 (모든 플랫폼)

```dart
import 'dart:typed_data';
import 'package:gr_camera_detector/gr_camera_detector.dart';

final detector = GrCameraDetector();

// 이미지 바이트에서 EXIF를 읽어 GR 카메라 감지
final Uint8List imageBytes = ...; // 이미지 바이트 데이터
final result = await detector.detectFromBytes(imageBytes);

if (result.isGrCamera) {
  print('GR 카메라 사진! 모델: ${result.model?.displayName}');
  print('확실한 판별: ${result.isConfirmed}');
}
```

### 파일명에서 감지

```dart
final result = detector.detectFromFilename('R0001234.JPG');

if (result.isGrCamera) {
  // 파일명 기반은 추정이므로 isConfirmed == false
  print('GR 카메라 추정 (파일명 기반)');
}
```

### 바이트 + 파일명 동시 감지

```dart
final result = await detector.detectFromBytes(
  imageBytes,
  filename: 'R0001234.JPG',
);

// EXIF + 파일명 모두 매칭 시 method == DetectionMethod.both
if (result.method == DetectionMethod.both) {
  print('EXIF + 파일명 모두 확인됨');
}
```

### 모델 정보 활용

```dart
final model = result.model;
if (model != null) {
  print('모델명: ${model.displayName}');
  print('HDF 필터: ${model.hasHdf}');
  print('모노크롬: ${model.isMonochrome}');
}
```

### Flutter 웹에서 사용

```dart
import 'package:gr_camera_detector/gr_camera_detector.dart';

// File picker로 선택한 파일의 바이트 데이터 사용
final bytes = await pickedFile.readAsBytes();
final result = await GrCameraDetector().detectFromBytes(
  bytes,
  filename: pickedFile.name,
);
```

## Detection Methods

| 방법                       | 정확도 | `isConfirmed` | 설명                    |
| -------------------------- | ------ | ------------- | ----------------------- |
| `DetectionMethod.exif`     | 높음   | ✅ `true`     | EXIF 메타데이터 확인    |
| `DetectionMethod.filename` | 낮음   | ❌ `false`    | 파일명 패턴 추정        |
| `DetectionMethod.both`     | 최고   | ✅ `true`     | EXIF + 파일명 모두 확인 |
| `DetectionMethod.none`     | —      | ❌ `false`    | 감지 안됨               |

## Additional information

- 파일명 감지는 다른 카메라도 비슷한 패턴을 사용할 수 있으므로 참고용입니다.
- 새로운 GR 모델이 출시되면 업데이트될 예정입니다.
- 버그 리포트나 기능 요청은
  [GitHub Issues](https://github.com/YOUR_USERNAME/gr_camera_detector/issues)에
  남겨주세요.
