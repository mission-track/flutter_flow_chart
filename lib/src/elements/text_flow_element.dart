import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/elements/connection_params.dart';

class TextFlowElement extends FlowElement {
  TextFlowElement({
    required String text,
    Color textColor = Colors.black,
    String? fontFamily,
    double textSize = 24,
    bool textIsBold = false,
    ElementKind kind = ElementKind.rectangle,
    Offset position = Offset.zero,
    Size size = Size.zero,
    List<Handler> handlers = const [
      Handler.topCenter,
      Handler.bottomCenter,
      Handler.rightCenter,
      Handler.leftCenter,
    ],
    double handlerSize = 15.0,
    Color backgroundColor = Colors.white,
    Color borderColor = Colors.blue,
    double borderThickness = 3,
    double elevation = 4,
    List<ConnectionParams>? next,
  }) : super(
          data: {
            'text': text,
            'textColor': textColor.value,
            'fontFamily': fontFamily,
            'textSize': textSize,
            'textIsBold': textIsBold,
          },
          builder: customBuilder,
          kind: kind,
          position: position,
          size: size,
          handlers: handlers,
          handlerSize: handlerSize,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderThickness: borderThickness,
          elevation: elevation,
          next: next,
        );

  static Widget customBuilder(
    BuildContext context,
    Map<String, dynamic> data,
    ElementKind kind,
  ) {
    return Text(
      data['text'] as String,
      style: TextStyle(
        color: Color(data['textColor'] as int),
        fontSize: data['textSize'] as double,
        fontWeight:
            (data['textIsBold'] as bool) ? FontWeight.bold : FontWeight.normal,
        fontFamily: data['fontFamily'] as String?,
      ),
    );
  }

  factory TextFlowElement.fromMap(Map<String, dynamic> map) {
    return TextFlowElement(
      text: map['data']['text'] as String,
      textColor: Color(map['data']['textColor'] as int),
      fontFamily: map['data']['fontFamily'] as String?,
      textSize: map['data']['textSize'] as double,
      textIsBold: map['data']['textIsBold'] as bool,
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

  // Attribute accessors for backward compatibility

  String get text => data['text'] as String;

  set text(String value) {
    data['text'] = value;
    notifyListeners();
  }

  Color get textColor => Color(data['textColor'] as int);

  set textColor(Color value) {
    data['textColor'] = value.value;
    notifyListeners();
  }

  String? get fontFamily => data['fontFamily'] as String?;

  set fontFamily(String? value) {
    data['fontFamily'] = value;
    notifyListeners();
  }

  double get textSize => data['textSize'] as double;

  set textSize(double value) {
    data['textSize'] = value;
    notifyListeners();
  }

  bool get textIsBold => data['textIsBold'] as bool;

  set textIsBold(bool value) {
    data['textIsBold'] = value;
    notifyListeners();
  }

  // Attribute setters for backward compatibility

  void setText(String value) {
    text = value;
  }

  void setTextColor(Color value) {
    textColor = value;
  }

  void setFontFamily(String? value) {
    fontFamily = value;
  }

  void setTextSize(double value) {
    textSize = value;
  }

  void setTextIsBold(bool value) {
    textIsBold = value;
  }

  @override
  void setData(Map<String, dynamic> data) {
    assert(data.containsKey('text'));
    assert(data.containsKey('textColor'));
    assert(data.containsKey('textSize'));
    assert(data.containsKey('textIsBold'));
    super.setData(data);
  }
}
