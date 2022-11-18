import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixels/src/pixel_palette.dart';
import 'dart:ui' as ui;

/// Displays a pixellated image using the data provided in [pixels], where each
/// byte is mapped to a color in the [palette]. The numer of horizontal and
/// vertical pixels are defined by [width] and [height].
class PixelImage extends StatefulWidget {
  /// Width in pixels.
  final int width;

  /// Height in pixels.
  final int height;

  /// The palette used by this image.
  final PixelPalette? palette;

  /// The [ByteData] representing the pixels in the image. Each byte corresponds
  /// to one pixel.
  final ByteData pixels;

  /// Creates a new [PixelImage].
  const PixelImage({
    required this.width,
    required this.height,
    this.palette,
    required this.pixels,
    super.key,
  });

  @override
  State<PixelImage> createState() => _PixelImageState();

  /// calculate the image's 2D area
  int get area => width * height;
}

class _PixelImageState extends State<PixelImage> {
  ui.Image? _uiImage;

  @override
  void initState() {
    super.initState();
    _updateUIImage();
  }

  Future<void> _updateUIImage() async {
    assert(widget.pixels.lengthInBytes == widget.area * 4);

    var immutableBuffer = await ui.ImmutableBuffer.fromUint8List(
        widget.pixels.buffer.asUint8List());
    var imageDescriptor = ui.ImageDescriptor.raw(
      immutableBuffer,
      width: widget.width,
      height: widget.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    var codec = await imageDescriptor.instantiateCodec(
      targetWidth: widget.width,
      targetHeight: widget.height,
    );

    var frameInfo = await codec.getNextFrame();
    codec.dispose();
    immutableBuffer.dispose();
    imageDescriptor.dispose();

    _uiImage = frameInfo.image;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.width / widget.height,
      child: _uiImage == null
          ? null
          : RawImage(
              image: _uiImage,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
    );
  }

  @override
  void didUpdateWidget(covariant PixelImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      // If the image changes dimension, we don't want to risk showing the old
      // image until the new one is prepared.
      _uiImage = null;
    }
    _updateUIImage();
  }
}
