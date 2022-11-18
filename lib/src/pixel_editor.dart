import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixels/src/editable_pixel_image.dart';
import 'package:pixels/src/pallete_color_picker.dart';
import 'package:pixels/src/gradient_color_picker.dart';

/// A pixel editor widget where the colors and dimensions are specified in the
/// [controller]. Whenver a pixel is set, [onSetPixel] is called. The pixel
/// editor displays a pixel editing area and a palette where colors can be
/// choosen.
class PixelEditor extends StatefulWidget {
  /// The controller specifying the drawing area and palette of the editor.
  final PixelImageController controller;

  /// A callback for when a new pixel is set.
  final void Function(SetPixelDetails)? onSetPixel;

  /// Creates a new [PixelEditor].
  const PixelEditor({
    required this.controller,
    this.onSetPixel,
    super.key,
  });

  @override
  State<PixelEditor> createState() => _PixelEditorState();
}

class _PixelEditorState extends State<PixelEditor> {
  int _selectedColorIndex = 0;
  late Color _selectedColor;
  late Color _finalColor;
  double _selectedLuminosity = 0.5;

  /// Mixes [colorIn] by luminosity `L`
  /// L < 0.5 will darken, S > 0.5 will brighten
  Color luminate(Color colorIn) {
    final double r = colorIn.red.toDouble();
    final double g = colorIn.green.toDouble();
    final double b = colorIn.blue.toDouble();
    final double L = 255 * (_selectedLuminosity * 2 - 1);
    final ri = clampDouble(r + L, 0, 255).toInt();
    final gi = clampDouble(g + L, 0, 255).toInt();
    final bi = clampDouble(b + L, 0, 255).toInt();

    return Color.fromARGB(colorIn.alpha, ri, gi, bi);
  }

  /// Given some delta [a] 0.0-1.0, sample a color from the primary color spectrum
  Color sampleRainbowColor(double a) {
    const pi2 = pi * 2.0;
    double r = ((sin(a * pi2 + 2) + 1) / 2) * 255;
    double g = ((sin(a * pi2 + 0) + 1) / 2) * 255;
    double b = ((sin(a * pi2 + 4) + 1) / 2) * 255;
    return Color.fromARGB(255, r.floor(), g.floor(), b.floor());
  }

  @override
  void initState() {
    _selectedColor = _finalColor = sampleRainbowColor(1.0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var isHorizontal = constraints.maxWidth > constraints.maxHeight;

      return Flex(
          direction: isHorizontal ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            EditablePixelImage(
              controller: widget.controller,
              onTappedPixel: handleTappedPixel,
            ),
            if (widget.controller.palette != null) ...[
              makePaletteColorPicker(isHorizontal),
            ] else ...[
              makeLumenGradientPicker(isHorizontal),
              makeRainbowGradientPicker(isHorizontal),
            ],
          ]);
    });
  }

// uses palette picker tool for color selection
  Widget makePaletteColorPicker(bool isHorizontal) {
    return PaletteColorPicker(
      direction: isHorizontal ? Axis.vertical : Axis.horizontal,
      palette: widget.controller.palette!,
      selectedIndex: _selectedColorIndex,
      onChanged: (index) {
        setState(() {
          _selectedColorIndex = index;
          _finalColor = _selectedColor =
              widget.controller.palette!.colors[_selectedColorIndex];
        });
      },
    );
  }

  // uses a linear equation to cycle through the rainbow
  Widget makeRainbowGradientPicker(bool isHorizontal) {
    return GradientColorPicker(
      equation: sampleRainbowColor,
      onSelected: (color) {
        setState(() {
          _finalColor = luminate(_selectedColor = color);
        });
      },
      direction: isHorizontal ? Axis.vertical : Axis.horizontal,
      sliderStartOffset: 1.0,
    );
  }

// uses a linear equation from black to white
  Widget makeLumenGradientPicker(bool isHorizontal) {
    return GradientColorPicker(
      equation: (y) {
        int r = (y * 255).floor();
        return Color.fromARGB(255, r, r, r);
      },
      onSelected: (color) {
        setState(() {
          // convert to [0.0, 1.0] range for 0-100% intensity
          _selectedLuminosity = color.red / 255;
          // mix
          _finalColor = luminate(_selectedColor);
        });
      },
      direction: isHorizontal ? Axis.vertical : Axis.horizontal,
      sliderColor: Colors.yellow,
      sliderStartOffset: _selectedLuminosity,
    );
  }

  void handleTappedPixel(details) {
    if (widget.controller.palette == null) {
      handleColorTap(details);
      return;
    }

    handlePaletteColorTap(details);
  }

  void handleColorTap(details) {
    widget.controller.setPixel(
      color: _finalColor,
      x: details.x,
      y: details.y,
    );
    if (widget.onSetPixel != null) {
      widget.onSetPixel!(
        SetPixelDetails._(
          tapDetails: details,
          colorValue: _finalColor,
        ),
      );
    }
  }

  void handlePaletteColorTap(details) {
    final Color color = widget.controller.palette!.colors[_selectedColorIndex];
    widget.controller.setPixel(
      color: color,
      x: details.x,
      y: details.y,
    );
    if (widget.onSetPixel != null) {
      widget.onSetPixel!(
        SetPixelDetails._(
          tapDetails: details,
          colorIndex: _selectedColorIndex,
          colorValue: color,
        ),
      );
    }
  }
}

/// Details of a newly set pixel.
class SetPixelDetails {
  /// Information about where the pixel is located.
  final PixelTapDetails tapDetails;

  /// The newly set palette color index of the pixel.
  final int? colorIndex;

  /// The newly set color value of the pixel.
  final Color colorValue;

  SetPixelDetails._(
      {required this.tapDetails, this.colorIndex, required this.colorValue});
}
