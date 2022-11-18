import 'dart:math';

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

  /// Changes the slider gizmo color
  final Color sliderColor;

  /// Sets the gizmo starting position
  final double sliderStartOffset;

  /// Creates a new [GradientColorPicker].
  const GradientColorPicker({
    required this.equation,
    required this.onSelected,
    this.direction = Axis.horizontal,
    this.crossAxisWidth = 32.0,
    this.sliderColor = Colors.white,
    this.sliderStartOffset = 0.5,
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
                onTap: (x, y) =>
                    onSelected(equation(direction == Axis.horizontal ? x : y)),
                bands: bands,
                sliderColor: sliderColor,
                sliderStartOffset: sliderStartOffset,
                direction: direction),
          )
        ],
      ),
    );
  }
}

class _GradientColorPickerWell extends StatefulWidget {
  final Function(double x, double y) onTap;
  final GlobalKey colorGradKey = GlobalKey(debugLabel: "colorGradient");
  final Color Function(double y) equation;
  final int bands;
  final Color sliderColor;
  final double sliderStartOffset;
  final Axis direction;

  _GradientColorPickerWell(
      {required this.equation,
      required this.onTap,
      required this.bands,
      required this.sliderColor,
      required this.sliderStartOffset,
      required this.direction});

  Point pointFromTapDetails(details) {
    final RenderBox renderBox =
        colorGradKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final double x = details.localPosition.dx / size.width;
    final double y = details.localPosition.dy / size.height;
    return Point(x, y);
  }

  @override
  State<_GradientColorPickerWell> createState() {
    return _GradientColorPickerWellState();
  }
}

class _GradientColorPickerWellState extends State<_GradientColorPickerWell> {
  late double offset;

  @override
  void initState() {
    offset = widget.sliderStartOffset;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [];
    final List<double> stops = List.filled(widget.bands, 0.0);

    for (int i = 0; i < widget.bands; i++) {
      double alpha = i / widget.bands;

      if (widget.direction == Axis.horizontal) {
        alpha = 1.0 - alpha;
      }

      colors.add(widget.equation(alpha));
      stops[i] = i / widget.bands;
    }

    return GestureDetector(
        onTapDown: (details) {
          final p = widget.pointFromTapDetails(details);
          final double x = p.x.toDouble();
          final double y = p.y.toDouble();
          widget.onTap(x, y);
          setState(() {
            offset = widget.direction == Axis.horizontal ? x : y;
          });
        },
        child: Stack(children: [
          makeSliderGizmo(),
          Container(
            key: widget.colorGradKey,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: stops,
              colors: colors,
            )),
          ),
          makeSliderGizmo(),
        ]));
  }

  Widget makeSliderGizmo() => CustomPaint(
        size: Size.infinite,
        painter: GradientSliderPainter(
            offset, widget.direction, widget.bands, widget.sliderColor),
        willChange: true,
      );
}

/// Custom paints the slider gizmo
class GradientSliderPainter extends CustomPainter {
  /// The offset along the align axis
  double offset;

  /// The align axis
  Axis direction;

  /// Helps calculate where the slider should snap to
  int bands;

  /// The stroke color of the slider
  Color borderColor;

  /// Use the axis [offset] to position the gizmo
  GradientSliderPainter(
      this.offset, this.direction, this.bands, this.borderColor)
      : super();

  /// Paints a white rectangle representing the slider gizmo
  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2.0, offset * size.height);
    double width = size.width;
    double height = size.height / bands;

    if (direction == Axis.horizontal) {
      center = Offset(offset * size.width, size.height / 2.0);
      width = size.width / bands;
      height = size.height;
    }

    canvas.drawRect(
        Rect.fromCenter(center: center, width: width, height: height),
        Paint()
          ..color = borderColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke);
  }

  /// Never repaint unless changed
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
