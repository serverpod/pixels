import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixels/src/pixel_image.dart';
import 'package:pixels/src/pixel_palette.dart';

/// A [PixelImage] that can be manipulated using the [PixelImageController].
class EditablePixelImage extends StatefulWidget {
  /// The controller controlling this image.
  final PixelImageController controller;

  /// Callback for when a pixel is tapped on the image.
  final void Function(PixelTapDetails details)? onTappedPixel;

  /// Creates a new [EditablePixelImage].
  const EditablePixelImage({
    required this.controller,
    this.onTappedPixel,
    super.key,
  });

  @override
  State<EditablePixelImage> createState() => _EditablePixelImageState();
}

class _EditablePixelImageState extends State<EditablePixelImage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_pixelValueChanged);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_pixelValueChanged);
  }

  void _pixelValueChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.controller.width / widget.controller.height,
      child: LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            var xLocal = details.localPosition.dx;
            var yLocal = details.localPosition.dy;

            var x = widget.controller.width * xLocal ~/ constraints.maxWidth;
            var y = widget.controller.height * yLocal ~/ constraints.maxHeight;

            if (widget.onTappedPixel != null) {
              widget.onTappedPixel!(
                PixelTapDetails._(
                  x: x,
                  y: y,
                  index: y * widget.controller.width + x,
                  localPosition: details.localPosition,
                ),
              );
            }
          },
          child: PixelImage(
            width: widget.controller.value.width,
            height: widget.controller.value.height,
            palette: widget.controller.value.palette,
            pixels: widget.controller.value.pixels,
          ),
        );
      }),
    );
  }
}

/// Provides details about a tapped pixel on an [EditablePixelImage].
class PixelTapDetails {
  /// The x location of the pixel.
  final int x;

  /// The y location of the pixel.
  final int y;

  /// The index of the pixel in the [ByteData] of the image.
  final int index;

  /// Position in coordinates local to the Widget itself.
  final Offset localPosition;

  const PixelTapDetails._({
    required this.x,
    required this.y,
    required this.index,
    required this.localPosition,
  });
}

class _PixelImageValue {
  final ByteData pixels;
  final PixelPalette palette;
  final int width;
  final int height;

  const _PixelImageValue({
    required this.pixels,
    required this.palette,
    required this.width,
    required this.height,
  });
}

/// Controller for an [EditablePixelImage]. Use it to listen to taps on the
/// image or to set or replace pixels in the image.
class PixelImageController extends ValueNotifier<_PixelImageValue> {
  late Uint8List _pixelBytes;

  /// The palette of the [EditablePixelImage] controlled by the controller.
  final PixelPalette palette;

  /// Height in pixels of the [EditablePixelImage] controlled by the controller.
  final int height;

  /// Width in pixels of the [EditablePixelImage] controlled by the controller.
  final int width;

  /// Callback when a pixel is tapped on the [EditablePixelImage] controlled by
  /// the controller.
  final void Function(PixelTapDetails details)? onTappedPixel;

  /// Creates a new [PixelImageController].
  PixelImageController({
    ByteData? pixels,
    required this.palette,
    required this.width,
    required this.height,
    this.onTappedPixel,
  }) : super(_PixelImageValue(
          pixels: pixels ?? _emptyPixels(),
          palette: palette,
          width: width,
          height: height,
        )) {
    _pixelBytes = value.pixels.buffer.asUint8List();
    assert(_pixelBytes.length == width * height);
  }

  static ByteData _emptyPixels() {
    var bytes = Uint8List(64 * 64);
    return bytes.buffer.asByteData();
  }

  /// Gets or sets the [ByteData] of the [EditablePixelImage] controlled by the
  /// controller.
  ByteData get pixels => _pixelBytes.buffer.asByteData();

  set pixels(ByteData pixels) {
    assert(pixels.lengthInBytes == width * height);
    _update();
  }

  /// Sets a specific pixel in teh [EditablePixelImage] controlled by the
  /// controller.
  void setPixel({
    required int pixel,
    required int x,
    required int y,
  }) {
    _pixelBytes[y * width + x] = pixel;
    _update();
  }

  void _update() {
    value = _PixelImageValue(
      pixels: pixels,
      palette: palette,
      width: width,
      height: height,
    );
  }
}
