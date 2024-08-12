import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/connection_params.dart';
import 'package:flutter_flow_chart/src/common_types.dart';
import 'package:uuid/uuid.dart';

enum ElementKind {
  rectangle,
  diamond,
  storage,
  oval,
  parallelogram,
  hexagon,
}

enum Handler {
  topCenter,
  bottomCenter,
  rightCenter,
  leftCenter;

  Alignment toAlignment() {
    switch (this) {
      case Handler.topCenter:
        return Alignment.topCenter;
      case Handler.bottomCenter:
        return Alignment.bottomCenter;
      case Handler.rightCenter:
        return Alignment.centerRight;
      case Handler.leftCenter:
        return Alignment.centerLeft;
    }
  }
}

class FlowElement extends ChangeNotifier {
  FlowElement({
    required this.data,
    required this.builder,
    Offset position = Offset.zero,
    this.size = Size.zero,
    required this.kind,
    this.handlers = const [
      Handler.topCenter,
      Handler.bottomCenter,
      Handler.rightCenter,
      Handler.leftCenter,
    ],
    this.handlerSize = 15.0,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.blue,
    this.borderThickness = 3,
    this.elevation = 4,
    List<ConnectionParams>? next,
  })  : next = next ?? [],
        id = const Uuid().v4(),
        isResizing = false,
        position = position -
            Offset(
              size.width / 2 + handlerSize / 2,
              size.height / 2 + handlerSize / 2,
            );

  factory FlowElement.fromMap(
      Map<String, dynamic> map, FlowElementBuilder builder) {
    return FlowElement(
      data: map['data'] as Map<String, dynamic>,
      builder: builder,
      kind: ElementKind.values[map['kind'] as int],
      size: Size(map['size.width'] as double, map['size.height'] as double),
      handlers: List<Handler>.from(
        (map['handlers'] as List<dynamic>).map<Handler>(
          (x) => Handler.values[x as int],
        ),
      ),
      handlerSize: map['handlerSize'] as double,
      backgroundColor: Color(map['backgroundColor'] as int),
      borderColor: Color(map['borderColor'] as int),
      borderThickness: map['borderThickness'] as double,
      elevation: map['elevation'] as double,
      next: (map['next'] as List).isNotEmpty
          ? List<ConnectionParams>.from(
              (map['next'] as List<dynamic>).map<dynamic>(
                (x) => ConnectionParams.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    )
      ..setId(map['id'] as String)
      ..position = Offset(
        map['positionDx'] as double,
        map['positionDy'] as double,
      );
  }

  String id;
  Offset position;
  Size size;
  Map<String, dynamic> data;
  FlowElementBuilder builder;
  ElementKind kind;
  List<Handler> handlers;
  double handlerSize;
  Color backgroundColor;
  Color borderColor;
  double borderThickness;
  double elevation;
  List<ConnectionParams> next;
  bool isResizing;

  Offset getHandlerPosition(Alignment alignment) {
    return Offset(
      position.dx + (size.width * ((alignment.x + 1) / 2)) + handlerSize / 2,
      position.dy + (size.height * ((alignment.y + 1) / 2) + handlerSize / 2),
    );
  }

  void setIsResizing(bool resizing) {
    isResizing = resizing;
    notifyListeners();
  }

  void setScale(double currentZoom, double factor) {
    size = size / currentZoom * factor;
    handlerSize = handlerSize / currentZoom * factor;
    for (final element in next) {
      element.arrowParams.setScale(currentZoom, factor);
    }
    notifyListeners();
  }

  void setId(String id) {
    this.id = id;
  }

  void changePosition(Offset newPosition) {
    position = newPosition;
    notifyListeners();
  }

  void changeSize(Size newSize) {
    size = newSize;
    if (size.width < 40) size = Size(40, size.height);
    if (size.height < 40) size = Size(size.width, 40);
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    backgroundColor = color;
    notifyListeners();
  }

  void setBorderColor(Color color) {
    borderColor = color;
    notifyListeners();
  }

  void setBorderThickness(double thickness) {
    borderThickness = thickness;
    notifyListeners();
  }

  void setElevation(double newElevation) {
    elevation = newElevation;
    notifyListeners();
  }

  void setHandlerSize(double size) {
    handlerSize = size;
    notifyListeners();
  }

  void setKind(ElementKind newKind) {
    kind = newKind;
    notifyListeners();
  }

  void setData(Map<String, dynamic> newData) {
    data = newData;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'positionDx': position.dx,
      'positionDy': position.dy,
      'size.width': size.width,
      'size.height': size.height,
      'data': data,
      'id': id,
      'kind': kind.index,
      'handlers': handlers.map((x) => x.index).toList(),
      'handlerSize': handlerSize,
      'backgroundColor': backgroundColor.value,
      'borderColor': borderColor.value,
      'borderThickness': borderThickness,
      'elevation': elevation,
      'next': next.map((x) => x.toMap()).toList(),
    };
  }
}
