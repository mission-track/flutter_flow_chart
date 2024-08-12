import 'package:flutter/widgets.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';

typedef HandlerCallback = void Function(
  BuildContext context,
  Offset position,
  Handler handler,
  FlowElement element,
);

typedef ElementCallback = void Function(
  BuildContext context,
  Offset position,
  FlowElement element,
);

typedef DashboardCallback = void Function(
    BuildContext context, Offset position);

typedef PivotCallback = void Function(BuildContext context, Pivot pivot);

typedef ConnectionListener = void Function(
  FlowElement srcElement,
  FlowElement destElement,
);

typedef FlowElementBuilder = Widget Function(
  BuildContext context,
  Map<String, dynamic> data,
  ElementKind kind,
);
