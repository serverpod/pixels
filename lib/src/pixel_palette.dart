import 'package:flutter/material.dart';

/// An indexed palette where each index of the [colors] list represents a color.
class PixelPalette {
  /// List of colors in the palette.
  final List<Color> colors;

  /// Creates a new [PixelPalette] with the provided colors.
  const PixelPalette({required this.colors});

  /// A [PixelPalette] with the colors used on Commodore 64.
  const PixelPalette.c64()
      : colors = const [
          Color(0xFF000000),
          Color(0xFFFFFFFF),
          Color(0xFF880000),
          Color(0xFFAAFFEE),
          Color(0xFFCC44CC),
          Color(0xFF00CC55),
          Color(0xFF0000AA),
          Color(0xFFEEEE77),
          Color(0xFFDD8855),
          Color(0xFF664400),
          Color(0xFFFF7777),
          Color(0xFF333333),
          Color(0xFF777777),
          Color(0xFFAAFF66),
          Color(0xFF0088FF),
          Color(0xFFBBBBBB),
        ];

  /// A [PixelPalette] with the colors used by r/place.
  const PixelPalette.rPlace()
      : colors = const [
          Color(0xFF222222),
          Color(0xFF888888),
          Color(0xFFE4E4E4),
          Color(0xFFFFFFFF),
          Color(0xFFFFA7D1),
          Color(0xFFE50000),
          Color(0xFFE59500),
          Color(0xFFA06A42),
          Color(0xFFE5D900),
          Color(0xFF94E044),
          Color(0xFF02BE01),
          Color(0xFF00D3DD),
          Color(0xFF0083C7),
          Color(0xFF0000EA),
          Color(0xFFCF6EE4),
          Color(0xFF820080),
        ];
}
