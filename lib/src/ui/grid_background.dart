import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Defines grid parameters.
class GridBackgroundParams extends ChangeNotifier {
  /// [gridSquare] is the raw size of the grid square when scale is 1
  GridBackgroundParams({
    double gridSquare = 20.0,
    this.gridThickness = 0.7,
    this.secondarySquareStep = 5,
    this.backgroundColor = Colors.white,
    this.gridColor = Colors.black12,
    this.backgroundImage,
    this.showGrid = true,
    this.imageOpacity = 1.0,
    this.imageFit = BoxFit.cover,
    this.serializedBackgroundImage,
    void Function(double scale)? onScaleUpdate,
  }) : rawGridSquareSize = gridSquare {
    if (onScaleUpdate != null) {
      _onScaleUpdateListeners.add(onScaleUpdate);
    }
  }

  ///
  factory GridBackgroundParams.fromMap(Map<String, dynamic> map) {
    final params = GridBackgroundParams(
      gridSquare: map['gridSquare'] as double? ?? 20.0,
      gridThickness: map['gridThickness'] as double? ?? 0.7,
      secondarySquareStep: map['secondarySquareStep'] as int? ?? 5,
      backgroundColor: Color(map['backgroundColor'] as int? ?? 0xFFFFFFFF),
      gridColor: Color(map['gridColor'] as int? ?? 0xFFFFFFFF),
      showGrid: map['showGrid'] as bool? ?? true,
      imageOpacity: map['imageOpacity'] as double? ?? 1.0,
      imageFit: _boxFitFromString(map['imageFit'] as String? ?? 'cover'),
      serializedBackgroundImage: map['backgroundImage'] as String?,
    )
      ..scale = map['scale'] as double? ?? 1.0
      .._offset = Offset(
        map['offset.dx'] as double? ?? 0.0,
        map['offset.dy'] as double? ?? 0.0,
      );

    if (params.serializedBackgroundImage != null) {
      params._setBackgroundImageFromSerialized(params.serializedBackgroundImage!);
    }

    return params;
  }

  /// Helper method to convert string to BoxFit enum
  static BoxFit _boxFitFromString(String value) {
    switch (value) {
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'none':
        return BoxFit.none;
      case 'scaleDown':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  /// Helper method to convert BoxFit enum to string
  static String _boxFitToString(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return 'contain';
      case BoxFit.cover:
        return 'cover';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitHeight:
        return 'fitHeight';
      case BoxFit.fitWidth:
        return 'fitWidth';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scaleDown';
    }
  }

  /// Unscaled size of the grid square
  /// i.e. the size of the square when scale is 1
  final double rawGridSquareSize;

  /// Thickness of lines.
  final double gridThickness;

  /// How many vertical or horizontal lines to draw the marked lines.
  final int secondarySquareStep;

  /// Grid background color.
  final Color backgroundColor;

  /// Grid lines color.
  final Color gridColor;

  /// Background image for the grid
  ImageProvider? backgroundImage;

  /// Serialized background image
  String? serializedBackgroundImage;

  /// Whether to show the grid lines
  bool showGrid;

  /// Opacity of the background image (0.0 to 1.0)
  double imageOpacity;

  /// How to fit the background image
  BoxFit imageFit;

  /// offset to move the grid
  Offset _offset = Offset.zero;

  /// Scale of the grid.
  double scale = 1;

  /// Add listener for scaling
  void addOnScaleUpdateListener(void Function(double scale) listener) {
    _onScaleUpdateListeners.add(listener);
  }

  /// Remove listener for scaling
  void removeOnScaleUpdateListener(void Function(double scale) listener) {
    _onScaleUpdateListeners.remove(listener);
  }

  final List<void Function(double scale)> _onScaleUpdateListeners = [];

  ///
  set offset(Offset delta) {
    _offset += delta;
    notifyListeners();
  }

  ///
  void setScale(double factor, Offset focalPoint) {
    _offset = Offset(
      focalPoint.dx * (1 - factor),
      focalPoint.dy * (1 - factor),
    );
    scale = factor;

    for (final listener in _onScaleUpdateListeners) {
      listener(scale);
    }
    notifyListeners();
  }

  /// Set the background image
  Future<void> setBackgroundImage(ImageProvider? imageProvider) async {
    backgroundImage = imageProvider;
    notifyListeners();

    if (imageProvider != null) {
      imageProvider.resolve(ImageConfiguration.empty).addListener(
        ImageStreamListener(
          (ImageInfo info, _) async {
            final imageData = await info.image.toByteData(format: ui.ImageByteFormat.png);
            serializedBackgroundImage = base64Encode(imageData!.buffer.asUint8List());
          },
        ),
      );
    }
  }

  /// Set whether to show the grid
  void setShowGrid(bool show) {
    showGrid = show;
    notifyListeners();
  }

  /// Set the opacity of the background image
  void setImageOpacity(double opacity) {
    imageOpacity = opacity.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Set how to fit the background image
  void setImageFit(BoxFit fit) {
    imageFit = fit;
    notifyListeners();
  }

  /// size of the grid square with scale applied
  double get gridSquare => rawGridSquareSize * scale;

  ///
  Offset get offset => _offset;

  ///
  Map<String, dynamic> toMap() {
    return {
      'offset.dx': _offset.dx,
      'offset.dy': _offset.dy,
      'scale': scale,
      'gridSquare': rawGridSquareSize,
      'gridThickness': gridThickness,
      'secondarySquareStep': secondarySquareStep,
      'backgroundColor': backgroundColor.value,
      'gridColor': gridColor.value,
      'showGrid': showGrid,
      'imageOpacity': imageOpacity,
      'imageFit': _boxFitToString(imageFit),
      'backgroundImage': serializedBackgroundImage,
    };
  }

  Future<void> _setBackgroundImageFromSerialized(String serializedImage) async {
    backgroundImage = Image.memory(base64Decode(serializedImage)).image;
    notifyListeners();
  }
}

/// Uses a CustomPainter to draw a grid with the given parameters
class GridBackground extends StatelessWidget {
  GridBackground({
    super.key,
    GridBackgroundParams? params,
  }) : params = params ?? GridBackgroundParams();
  final GridBackgroundParams params;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: params,
      builder: (context, _) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: _GridBackgroundPainter(
              params: params,
              dx: params.offset.dx,
              dy: params.offset.dy,
              repaint: params,
            ),
          ),
        );
      },
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  _GridBackgroundPainter({
    required this.params,
    required this.dx,
    required this.dy,
    required Listenable repaint,
  }) : super(repaint: repaint) {
    _loadImageIfNeeded();
  }

  final GridBackgroundParams params;
  final double dx;
  final double dy;
  ui.Image? _image;
  ImageStreamListener? _imageListener;

  void _loadImageIfNeeded() {
    // Clean up previous listener if exists
    if (_imageListener != null && params.backgroundImage != null) {
      params.backgroundImage!.resolve(ImageConfiguration.empty).removeListener(_imageListener!);
      _imageListener = null;
    }

    if (params.backgroundImage != null) {
      final ImageStream imageStream = params.backgroundImage!.resolve(ImageConfiguration.empty);
      _imageListener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          _image = info.image;
          if (!synchronousCall) {
            params.notifyListeners();
          }
        },
        onError: (exception, stackTrace) {
          print('Error loading image: $exception');
          _image = null;
          params.notifyListeners();
        },
      );
      
      imageStream.addListener(_imageListener!);
    } else {
      _image = null;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Background
    paint.color = params.backgroundColor;
    canvas.drawRect(
      Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
      paint,
    );

    // Draw background image if available and loaded
    if (_image != null) {
      _drawBackgroundImage(canvas, size, _image!);
    }

    // Only draw grid if showGrid is true
    if (params.showGrid) {
      _drawGrid(canvas, size);
    }
  }

  void _drawBackgroundImage(Canvas canvas, Size size, ui.Image image) {
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Colors.white.withOpacity(params.imageOpacity);

    final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final destRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Apply different fitting based on imageFit
    final Rect finalRect;
    switch (params.imageFit) {
      case BoxFit.cover:
        finalRect = _coverRect(srcRect, destRect);
        break;
      case BoxFit.contain:
        finalRect = _containRect(srcRect, destRect);
        break;
      case BoxFit.fill:
        finalRect = destRect;
        break;
      case BoxFit.fitWidth:
        finalRect = _fitWidthRect(srcRect, destRect);
        break;
      case BoxFit.fitHeight:
        finalRect = _fitHeightRect(srcRect, destRect);
        break;
      case BoxFit.none:
        finalRect = Rect.fromLTWH(
          destRect.left,
          destRect.top,
          srcRect.width,
          srcRect.height,
        );
        break;
      case BoxFit.scaleDown:
        final containRect = _containRect(srcRect, destRect);
        finalRect = srcRect.width <= destRect.width && srcRect.height <= destRect.height
            ? Rect.fromLTWH(
                destRect.left,
                destRect.top,
                srcRect.width,
                srcRect.height,
              )
            : containRect;
        break;
    }

    canvas.drawImageRect(image, srcRect, finalRect, paint);
  }

  Rect _coverRect(Rect srcRect, Rect destRect) {
    final double srcAspectRatio = srcRect.width / srcRect.height;
    final double destAspectRatio = destRect.width / destRect.height;

    final double width;
    final double height;
    
    if (srcAspectRatio > destAspectRatio) {
      height = destRect.height;
      width = height * srcAspectRatio;
    } else {
      width = destRect.width;
      height = width / srcAspectRatio;
    }

    final double left = destRect.left + (destRect.width - width) / 2;
    final double top = destRect.top + (destRect.height - height) / 2;
    
    return Rect.fromLTWH(left, top, width, height);
  }

  Rect _containRect(Rect srcRect, Rect destRect) {
    final double srcAspectRatio = srcRect.width / srcRect.height;
    final double destAspectRatio = destRect.width / destRect.height;

    final double width;
    final double height;
    
    if (srcAspectRatio < destAspectRatio) {
      height = destRect.height;
      width = height * srcAspectRatio;
    } else {
      width = destRect.width;
      height = width / srcAspectRatio;
    }

    final double left = destRect.left + (destRect.width - width) / 2;
    final double top = destRect.top + (destRect.height - height) / 2;
    
    return Rect.fromLTWH(left, top, width, height);
  }

  Rect _fitWidthRect(Rect srcRect, Rect destRect) {
    final double srcAspectRatio = srcRect.width / srcRect.height;
    final double width = destRect.width;
    final double height = width / srcAspectRatio;
    final double left = destRect.left;
    final double top = destRect.top + (destRect.height - height) / 2;
    
    return Rect.fromLTWH(left, top, width, height);
  }

  Rect _fitHeightRect(Rect srcRect, Rect destRect) {
    final double srcAspectRatio = srcRect.width / srcRect.height;
    final double height = destRect.height;
    final double width = height * srcAspectRatio;
    final double left = destRect.left + (destRect.width - width) / 2;
    final double top = destRect.top;
    
    return Rect.fromLTWH(left, top, width, height);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint();
    
    // grid
    paint.color = params.gridColor;
    paint.style = PaintingStyle.stroke;

    // Calculate the starting points for x and y
    final startX = dx % (params.gridSquare * params.secondarySquareStep);
    final startY = dy % (params.gridSquare * params.secondarySquareStep);

    // Calculate the number of lines to draw outside the visible area
    const extraLines = 2;

    // Draw vertical lines
    for (var x = startX - extraLines * params.gridSquare;
        x < size.width + extraLines * params.gridSquare;
        x += params.gridSquare) {
      paint.strokeWidth = ((x - startX) / params.gridSquare).round() %
                  params.secondarySquareStep ==
              0
          ? params.gridThickness * 2.0
          : params.gridThickness;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (var y = startY - extraLines * params.gridSquare;
        y < size.height + extraLines * params.gridSquare;
        y += params.gridSquare) {
      paint.strokeWidth = ((y - startY) / params.gridSquare).round() %
                  params.secondarySquareStep ==
              0
          ? params.gridThickness * 2.0
          : params.gridThickness;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridBackgroundPainter oldDelegate) {
    // Always clean up the old delegate's image listener
    if (oldDelegate._imageListener != null && oldDelegate.params.backgroundImage != null) {
      oldDelegate.params.backgroundImage!.resolve(ImageConfiguration.empty).removeListener(oldDelegate._imageListener!);
      oldDelegate._imageListener = null;
    }
    
    // If the image provider has changed, load the new image
    if (oldDelegate.params.backgroundImage != params.backgroundImage) {
      _loadImageIfNeeded();
    }
    
    return oldDelegate.dx != dx || 
           oldDelegate.dy != dy || 
           oldDelegate.params.showGrid != params.showGrid ||
           oldDelegate.params.backgroundImage != params.backgroundImage ||
           oldDelegate.params.imageOpacity != params.imageOpacity ||
           oldDelegate.params.imageFit != params.imageFit ||
           oldDelegate._image != _image;
  }
}
