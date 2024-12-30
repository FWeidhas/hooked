import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4281035334),
      surfaceTint: Color(4281035334),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4289721028),
      onPrimaryContainer: Color(4278198544),
      secondary: Color(4283392852),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4291946709),
      onSecondaryContainer: Color(4278984468),
      tertiary: Color(4282082416),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4290767352),
      onTertiaryContainer: Color(4278198055),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294376436),
      onSurface: Color(4279770393),
      onSurfaceVariant: Color(4282468674),
      outline: Color(4285626737),
      outlineVariant: Color(4290824640),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086509),
      inversePrimary: Color(4287878569),
      primaryFixed: Color(4289721028),
      onPrimaryFixed: Color(4278198544),
      primaryFixedDim: Color(4287878569),
      onPrimaryFixedVariant: Color(4278931760),
      secondaryFixed: Color(4291946709),
      onSecondaryFixed: Color(4278984468),
      secondaryFixedDim: Color(4290104506),
      onSecondaryFixedVariant: Color(4281813821),
      tertiaryFixed: Color(4290767352),
      onTertiaryFixed: Color(4278198055),
      tertiaryFixedDim: Color(4288925147),
      onTertiaryFixedVariant: Color(4280372312),
      surfaceDim: Color(4292271061),
      surfaceBright: Color(4294376436),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293981678),
      surfaceContainer: Color(4293586920),
      surfaceContainerHigh: Color(4293257955),
      surfaceContainerHighest: Color(4292863197),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278471981),
      surfaceTint: Color(4281035334),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4282548571),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281550649),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4284775018),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4280109140),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283595655),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294376436),
      onSurface: Color(4279770393),
      onSurfaceVariant: Color(4282205502),
      outline: Color(4284047706),
      outlineVariant: Color(4285824373),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086509),
      inversePrimary: Color(4287878569),
      primaryFixed: Color(4282548571),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4280837956),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4284775018),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283195730),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283595655),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4281885294),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292271061),
      surfaceBright: Color(4294376436),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293981678),
      surfaceContainer: Color(4293586920),
      surfaceContainerHigh: Color(4293257955),
      surfaceContainerHighest: Color(4292863197),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278200597),
      surfaceTint: Color(4281035334),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4278471981),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4279445018),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4281550649),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278199855),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4280109140),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294376436),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280165920),
      outline: Color(4282205502),
      outlineVariant: Color(4282205502),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086509),
      inversePrimary: Color(4290313165),
      primaryFixed: Color(4278471981),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278203420),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4281550649),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280103204),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4280109140),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278202940),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292271061),
      surfaceBright: Color(4294376436),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293981678),
      surfaceContainer: Color(4293586920),
      surfaceContainerHigh: Color(4293257955),
      surfaceContainerHighest: Color(4292863197),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4287878569),
      surfaceTint: Color(4287878569),
      onPrimary: Color(4278204703),
      primaryContainer: Color(4278931760),
      onPrimaryContainer: Color(4289721028),
      secondary: Color(4290104506),
      onSecondary: Color(4280366376),
      secondaryContainer: Color(4281813821),
      onSecondaryContainer: Color(4291946709),
      tertiary: Color(4288925147),
      onTertiary: Color(4278400577),
      tertiaryContainer: Color(4280372312),
      onTertiaryContainer: Color(4290767352),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279178513),
      onSurface: Color(4292863197),
      onSurfaceVariant: Color(4290824640),
      outline: Color(4287271819),
      outlineVariant: Color(4282468674),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292863197),
      inversePrimary: Color(4281035334),
      primaryFixed: Color(4289721028),
      onPrimaryFixed: Color(4278198544),
      primaryFixedDim: Color(4287878569),
      onPrimaryFixedVariant: Color(4278931760),
      secondaryFixed: Color(4291946709),
      onSecondaryFixed: Color(4278984468),
      secondaryFixedDim: Color(4290104506),
      onSecondaryFixedVariant: Color(4281813821),
      tertiaryFixed: Color(4290767352),
      onTertiaryFixed: Color(4278198055),
      tertiaryFixedDim: Color(4288925147),
      onTertiaryFixedVariant: Color(4280372312),
      surfaceDim: Color(4279178513),
      surfaceBright: Color(4281678646),
      surfaceContainerLowest: Color(4278849292),
      surfaceContainerLow: Color(4279770393),
      surfaceContainer: Color(4280033565),
      surfaceContainerHigh: Color(4280691495),
      surfaceContainerHighest: Color(4281415217),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4288207277),
      surfaceTint: Color(4287878569),
      onPrimary: Color(4278197004),
      primaryContainer: Color(4284456566),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4290433214),
      onSecondary: Color(4278655503),
      secondaryContainer: Color(4286617221),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4289188575),
      onTertiary: Color(4278196512),
      tertiaryContainer: Color(4285437860),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279178513),
      onSurface: Color(4294442229),
      onSurfaceVariant: Color(4291087812),
      outline: Color(4288521629),
      outlineVariant: Color(4286416253),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292863197),
      inversePrimary: Color(4279128881),
      primaryFixed: Color(4289721028),
      onPrimaryFixed: Color(4278195464),
      primaryFixedDim: Color(4287878569),
      onPrimaryFixedVariant: Color(4278206243),
      secondaryFixed: Color(4291946709),
      onSecondaryFixed: Color(4278392074),
      secondaryFixedDim: Color(4290104506),
      onSecondaryFixedVariant: Color(4280760877),
      tertiaryFixed: Color(4290767352),
      onTertiaryFixed: Color(4278195225),
      tertiaryFixedDim: Color(4288925147),
      onTertiaryFixedVariant: Color(4278991687),
      surfaceDim: Color(4279178513),
      surfaceBright: Color(4281678646),
      surfaceContainerLowest: Color(4278849292),
      surfaceContainerLow: Color(4279770393),
      surfaceContainer: Color(4280033565),
      surfaceContainerHigh: Color(4280691495),
      surfaceContainerHighest: Color(4281415217),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4293918704),
      surfaceTint: Color(4287878569),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4288207277),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4293918704),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4290433214),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294311167),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4289188575),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279178513),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294311411),
      outline: Color(4291087812),
      outlineVariant: Color(4291087812),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292863197),
      inversePrimary: Color(4278202650),
      primaryFixed: Color(4289984200),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4288207277),
      onPrimaryFixedVariant: Color(4278197004),
      secondaryFixed: Color(4292210137),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4290433214),
      onSecondaryFixedVariant: Color(4278655503),
      tertiaryFixed: Color(4291030780),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4289188575),
      onTertiaryFixedVariant: Color(4278196512),
      surfaceDim: Color(4279178513),
      surfaceBright: Color(4281678646),
      surfaceContainerLowest: Color(4278849292),
      surfaceContainerLow: Color(4279770393),
      surfaceContainer: Color(4280033565),
      surfaceContainerHigh: Color(4280691495),
      surfaceContainerHighest: Color(4281415217),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
