import 'package:flutter/material.dart';

/// A gradient-equation based color picker. It can be displayed vertically or
/// horizontally depending on the [direction].
class GradientColorPicker extends StatelessWidget {
  /// Defines if the color picker should be displayed horizontally or
  /// vertically.
  final Axis direction;

  /// A callback for when the user picks a color.
  final void Function(Color color) onSelected;

  /// A callback to calculate the color
  final Color Function(double y) equation;

  /// The width or height (depending on it's direction) of the color picker.
  final double crossAxisWidth;

  /// Dictates the resolution of the visualized gradient. More = smoother.
  final int bands = 255;

  /// Creates a new [GradientColorPicker].
  const GradientColorPicker({
    required this.equation,
    required this.onSelected,
    this.direction = Axis.horizontal,
    this.crossAxisWidth = 32.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: direction == Axis.vertical ? crossAxisWidth : null,
      height: direction == Axis.horizontal ? crossAxisWidth : null,
      child: Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: _GradientColorPickerWell(
              equation: equation,
              onTap: (x, y) {
                onSelected(equation(y));
              },
              bands: bands,
            ),
          )
        ],
      ),
    );
  }
}

class _GradientColorPickerWell extends StatelessWidget {
  final Function(double x, double y) onTap;
  final GlobalKey colorGradKey = GlobalKey(debugLabel: "colorGradient");
  final Color Function(double y) equation;
  final int bands;

  _GradientColorPickerWell({
    required this.equation,
    required this.onTap,
    required this.bands,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [];
    final List<double> stops = List.filled(bands, 0.0);

    for (int i = 0; i < bands; i++) {
      colors.add(equation(i / bands));
      stops[i] = i / bands;
    }

    return GestureDetector(
        onTapDown: (details) {
          final RenderBox renderBox =
              colorGradKey.currentContext?.findRenderObject() as RenderBox;
          final size = renderBox.size;
          final double x = details.localPosition.dx / size.width;
          final double y = details.localPosition.dy / size.height;
          onTap(x, y);
        },
        child: Container(
          key: colorGradKey,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: stops,
            colors: colors,
          )),
        ));
  }
}
