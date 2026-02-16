/// Supported Ricoh GR camera models.
enum GrCameraModel {
  // GR DIGITAL series
  /// GR DIGITAL (2005)
  grDigital,

  /// GR DIGITAL II (2007)
  grDigitalII,

  /// GR DIGITAL III (2009)
  grDigitalIII,

  /// GR DIGITAL IV (2011)
  grDigitalIV,

  // GR series (2013~)
  /// GR (2013)
  gr,

  /// GR II (2015)
  grII,

  /// GR III (2019)
  grIII,

  /// GR IIIx (2021)
  grIIIx,

  /// GR III HDF - with Highlight Diffusion Filter
  grIIIHdf,

  /// GR IIIx HDF - with Highlight Diffusion Filter
  grIIIxHdf,

  // GR IV series (2025~2026)
  /// GR IV (2025)
  grIV,

  /// GR IV HDF - with Highlight Diffusion Filter
  grIVHdf,

  /// GR IV Monochrome - dedicated monochrome sensor
  grIVMono,

  /// Unknown GR model (Make is RICOH and Model contains "GR" but not in known list)
  unknown;

  /// Returns the display name for this model.
  String get displayName => switch (this) {
        grDigital => 'GR DIGITAL',
        grDigitalII => 'GR DIGITAL II',
        grDigitalIII => 'GR DIGITAL III',
        grDigitalIV => 'GR DIGITAL IV',
        gr => 'GR',
        grII => 'GR II',
        grIII => 'GR III',
        grIIIx => 'GR IIIx',
        grIIIHdf => 'GR III HDF',
        grIIIxHdf => 'GR IIIx HDF',
        grIV => 'GR IV',
        grIVHdf => 'GR IV HDF',
        grIVMono => 'GR IV Monochrome',
        unknown => 'Unknown GR',
      };

  /// Whether this model has a Highlight Diffusion Filter.
  bool get hasHdf => switch (this) {
        grIIIHdf || grIIIxHdf || grIVHdf => true,
        _ => false,
      };

  /// Whether this model has a dedicated monochrome sensor.
  bool get isMonochrome => this == grIVMono;
}

/// Mapping from EXIF Model strings to [GrCameraModel].
///
/// Keys are case-sensitive as they appear in EXIF data.
/// Multiple variations are included for models with known alternate strings.
const Map<String, GrCameraModel> grModelMapping = {
  // GR DIGITAL series
  'RICOH GR DIGITAL': GrCameraModel.grDigital,
  'GR DIGITAL': GrCameraModel.grDigital,
  'RICOH GR DIGITAL II': GrCameraModel.grDigitalII,
  'GR DIGITAL II': GrCameraModel.grDigitalII,
  'RICOH GR DIGITAL III': GrCameraModel.grDigitalIII,
  'GR DIGITAL III': GrCameraModel.grDigitalIII,
  'RICOH GR DIGITAL IV': GrCameraModel.grDigitalIV,
  'Ricoh GR Digital IV': GrCameraModel.grDigitalIV,
  'GR DIGITAL IV': GrCameraModel.grDigitalIV,

  // GR series
  'RICOH GR': GrCameraModel.gr,
  'GR': GrCameraModel.gr,
  'RICOH GR II': GrCameraModel.grII,
  'GR II': GrCameraModel.grII,
  'RICOH GR III': GrCameraModel.grIII,
  'GR III': GrCameraModel.grIII,
  'RICOH GR IIIx': GrCameraModel.grIIIx,
  'GR IIIx': GrCameraModel.grIIIx,
  'RICOH GR III HDF': GrCameraModel.grIIIHdf,
  'GR III HDF': GrCameraModel.grIIIHdf,
  'RICOH GR IIIx HDF': GrCameraModel.grIIIxHdf,
  'GR IIIx HDF': GrCameraModel.grIIIxHdf,

  // GR IV series
  'RICOH GR IV': GrCameraModel.grIV,
  'GR IV': GrCameraModel.grIV,
  'RICOH GR IV HDF': GrCameraModel.grIVHdf,
  'GR IV HDF': GrCameraModel.grIVHdf,
  'RICOH GR IV Monochrome': GrCameraModel.grIVMono,
  'GR IV Monochrome': GrCameraModel.grIVMono,
};

/// Known EXIF Make values for Ricoh cameras.
const Set<String> ricohMakeValues = {
  'RICOH',
  'Ricoh',
  'RICOH IMAGING COMPANY, LTD.',
};
