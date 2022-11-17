import 'dart:math';

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
  Color _selectedColor = const Color.fromARGB(255, 255, 255, 255);
  Color _finalColor = const Color.fromARGB(255, 255, 255, 255);
  double _selectedSaturation = 1.0;

  Color saturate(Color colorIn) {
    int r = (colorIn.red * _selectedSaturation).floor();
    int g = (colorIn.green * _selectedSaturation).floor();
    int b = (colorIn.blue * _selectedSaturation).floor();
    return Color.fromARGB(colorIn.alpha, r, g, b);
  }

  @override
  void initState() {
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
              makeSaturationGradientPicker(isHorizontal),
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
          _selectedColor =
              widget.controller.palette!.colors[_selectedColorIndex];
        });
      },
    );
  }

  // uses a linear equation to cycle through the rainbow
  Widget makeRainbowGradientPicker(bool isHorizontal) {
    return GradientColorPicker(
      equation: (y) {
        const pi2 = pi * 2.0;
        double r = ((sin(y * pi2 + 2) + 1) / 2) * 255;
        double g = ((sin(y * pi2 + 0) + 1) / 2) * 255;
        double b = ((sin(y * pi2 + 4) + 1) / 2) * 255;
        return Color.fromARGB(255, r.floor(), g.floor(), b.floor());
      },
      direction: isHorizontal ? Axis.vertical : Axis.horizontal,
      onSelected: (color) {
        setState(() {
          _finalColor = saturate(_selectedColor = color);
        });
      },
    );
  }

// uses a linear equation from black to white
  Widget makeSaturationGradientPicker(bool isHorizontal) {
    return GradientColorPicker(
      equation: (y) {
        int r = (y * 255).floor();
        return Color.fromARGB(255, r, r, r);
      },
      direction: isHorizontal ? Axis.vertical : Axis.horizontal,
      onSelected: (color) {
        setState(() {
          // convert to [0.0, 1.0] range for 0-100% intensity
          _selectedSaturation = color.red / 255;
          // mix
          _finalColor = saturate(_selectedColor);
        });
      },
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
    widget.controller.setPixelColor(
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
    widget.controller.setPixel(
      colorIndex: _selectedColorIndex,
      x: details.x,
      y: details.y,
    );
    if (widget.onSetPixel != null) {
      widget.onSetPixel!(
        SetPixelDetails._(
          tapDetails: details,
          colorIndex: _selectedColorIndex,
          colorValue: widget.controller.palette!.colors[_selectedColorIndex],
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
