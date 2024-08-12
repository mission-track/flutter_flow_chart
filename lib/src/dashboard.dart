import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';
import 'package:flutter_flow_chart/src/common_types.dart';
import 'package:uuid/uuid.dart';

class Dashboard<T extends FlowElement> extends ChangeNotifier {
  Dashboard({
    Offset? handlerFeedbackOffset,
    this.blockDefaultZoomGestures = false,
    this.minimumZoomFactor = 0.25,
    this.defaultArrowStyle = ArrowStyle.curve,
  })  : elements = [],
        _dashboardPosition = Offset.zero,
        dashboardSize = Size.zero,
        gridBackgroundParams = GridBackgroundParams() {
    this.handlerFeedbackOffset = handlerFeedbackOffset ??
        (kIsWeb
            ? Offset.zero
            : Platform.isIOS || Platform.isAndroid
                ? const Offset(0, -50)
                : Offset.zero);
  }

  factory Dashboard.fromMap(Map<String, dynamic> map,
      T Function(Map<String, dynamic>) elementBuilder) {
    final d = Dashboard<T>(
      defaultArrowStyle: ArrowStyle.values[map['arrowStyle'] as int? ?? 0],
    )
      ..elements = List<T>.from(
        (map['elements'] as List<dynamic>).map<T>(
          (x) => elementBuilder(x as Map<String, dynamic>),
        ),
      )
      ..dashboardSize = Size(
        map['dashboardSizeWidth'] as double? ?? 0,
        map['dashboardSizeHeight'] as double? ?? 0,
      );

    if (map['gridBackgroundParams'] != null) {
      d.gridBackgroundParams = GridBackgroundParams.fromMap(
        map['gridBackgroundParams'] as Map<String, dynamic>,
      );
    }
    d
      ..blockDefaultZoomGestures =
          map['blockDefaultZoomGestures'] as bool? ?? false
      ..minimumZoomFactor = map['minimumZoomFactor'] as double? ?? 0.25;

    return d;
  }

  List<T> elements;
  Offset _dashboardPosition;
  Size dashboardSize;
  final ArrowStyle defaultArrowStyle;
  late Offset handlerFeedbackOffset;
  GridBackgroundParams gridBackgroundParams;
  bool blockDefaultZoomGestures;
  double minimumZoomFactor;

  final List<ConnectionListener> _connectionListeners = [];

  void addConnectionListener(ConnectionListener listener) {
    _connectionListeners.add(listener);
  }

  void removeConnectionListener(ConnectionListener listener) {
    _connectionListeners.remove(listener);
  }

  void setGridBackgroundParams(GridBackgroundParams params) {
    gridBackgroundParams = params;
    notifyListeners();
  }

  void setHandlerFeedbackOffset(Offset offset) {
    handlerFeedbackOffset = offset;
  }

  void setElementResizable(
    T element,
    bool resizable, {
    bool notify = true,
  }) {
    element.isResizing = resizable;
    if (notify) notifyListeners();
  }

  void addElement(T element, {bool notify = true}) {
    if (element.id.isEmpty) {
      element.id = const Uuid().v4();
    }
    element.setScale(1, gridBackgroundParams.scale);
    elements.add(element);
    if (notify) {
      notifyListeners();
    }
  }

  void setArrowStyle(
    T src,
    T dest,
    ArrowStyle style, {
    bool notify = true,
    double tension = 1.0,
  }) {
    for (final conn in src.next) {
      if (conn.destElementId == dest.id) {
        conn.arrowParams.style = style;
        conn.arrowParams.tension = tension;
        break;
      }
    }
    if (notify) {
      notifyListeners();
    }
  }

  void setArrowStyleByHandler(
    T src,
    Handler handler,
    ArrowStyle style, {
    bool notify = true,
    double tension = 1.0,
  }) {
    final alignment = handler.toAlignment();
    for (final conn in src.next) {
      if (conn.arrowParams.startArrowPosition == alignment) {
        conn.arrowParams.tension = tension;
        conn.arrowParams.style = style;
      }
    }
    for (final element in elements) {
      for (final conn in element.next) {
        if (conn.arrowParams.endArrowPosition == alignment &&
            conn.destElementId == src.id) {
          conn.arrowParams.tension = tension;
          conn.arrowParams.style = style;
        }
      }
    }
    if (notify) {
      notifyListeners();
    }
  }

  int findElementIndexById(String id) {
    return elements.indexWhere((element) => element.id == id);
  }

  T? findElementById(String id) {
    try {
      return elements.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  ConnectionParams? findConnectionByElements(
    T srcElement,
    T destElement,
  ) {
    try {
      return srcElement.next
          .firstWhere((element) => element.destElementId == destElement.id);
    } catch (e) {
      return null;
    }
  }

  T? findSrcElementByDestElement(T dest) {
    for (final element in elements) {
      for (final connection in element.next) {
        if (connection.destElementId == dest.id) {
          return element;
        }
      }
    }
    return null;
  }

  void removeAllElements({bool notify = true}) {
    elements.clear();
    if (notify) notifyListeners();
  }

  void removeElementConnection(
    T element,
    Handler handler, {
    bool notify = true,
  }) {
    final alignment = handler.toAlignment();
    final isSrc = element.next.any(
        (connection) => connection.arrowParams.startArrowPosition == alignment);

    if (isSrc) {
      element.next.removeWhere(
        (handlerParam) =>
            handlerParam.arrowParams.startArrowPosition == alignment,
      );
    } else {
      final src = findSrcElementByDestElement(element);
      if (src != null) {
        src.next.removeWhere(
          (handlerParam) => handlerParam.destElementId == element.id,
        );
      }
    }

    if (notify) notifyListeners();
  }

  void dissectElementConnection(
    T element,
    Handler handler, {
    Offset? point,
    bool notify = true,
  }) {
    final alignment = handler.toAlignment();
    ConnectionParams? conn;
    var newPoint = point ?? Offset.zero;

    try {
      conn = element.next.firstWhere(
        (handlerParam) =>
            handlerParam.arrowParams.startArrowPosition == alignment,
      );
      if (conn.arrowParams.style != ArrowStyle.segmented) return;

      if (point == null) {
        final dest = findElementById(conn.destElementId);
        newPoint = (dest!
                    .getHandlerPosition(conn.arrowParams.endArrowPosition) +
                element
                    .getHandlerPosition(conn.arrowParams.startArrowPosition)) /
            2;
      }
    } catch (e) {
      final src = findSrcElementByDestElement(element)!;
      conn = src.next.firstWhere(
        (handlerParam) => handlerParam.destElementId == element.id,
      );
      if (conn.arrowParams.style != ArrowStyle.segmented) return;

      if (point == null) {
        newPoint = (element
                    .getHandlerPosition(conn.arrowParams.endArrowPosition) +
                src.getHandlerPosition(conn.arrowParams.startArrowPosition)) /
            2;
      }
    }

    conn.dissect(newPoint);
    if (notify) notifyListeners();
  }

  void removeDissection(Pivot pivot, {bool notify = true}) {
    for (final element in elements) {
      for (final connection in element.next) {
        connection.pivots.removeWhere((item) => item == pivot);
      }
    }
    if (notify) notifyListeners();
  }

  void removeConnectionByElements(
    T srcElement,
    T destElement, {
    bool notify = true,
  }) {
    srcElement.next.removeWhere(
      (handlerParam) => handlerParam.destElementId == destElement.id,
    );
    if (notify) notifyListeners();
  }

  void removeElementConnections(T element, {bool notify = true}) {
    element.next.clear();
    if (notify) notifyListeners();
  }

  void removeElementById(String id, {bool notify = true}) {
    String? elementId;
    elements.removeWhere((element) {
      if (element.id == id) {
        elementId = element.id;
        return true;
      }
      return false;
    });

    if (elementId != null) {
      for (final e in elements) {
        e.next.removeWhere(
            (handlerParams) => handlerParams.destElementId == elementId);
      }
    }
    if (notify) notifyListeners();
  }

  bool removeElement(T element, {bool notify = true}) {
    final removed = elements.remove(element);
    if (removed) {
      for (final e in elements) {
        e.next.removeWhere(
            (handlerParams) => handlerParams.destElementId == element.id);
      }
    }
    if (notify) notifyListeners();
    return removed;
  }

  void setZoomFactor(double factor, {Offset? focalPoint}) {
    if (factor < minimumZoomFactor || gridBackgroundParams.scale == factor) {
      return;
    }

    focalPoint ??= Offset(dashboardSize.width / 2, dashboardSize.height / 2);

    for (final element in elements) {
      element
        ..position = (element.position - focalPoint) /
                gridBackgroundParams.scale *
                factor +
            focalPoint
        ..setScale(gridBackgroundParams.scale, factor);
      for (final conn in element.next) {
        for (final pivot in conn.pivots) {
          pivot.setScale(gridBackgroundParams.scale, focalPoint, factor);
        }
      }
    }

    gridBackgroundParams.setScale(factor, focalPoint);
    notifyListeners();
  }

  double get zoomFactor => gridBackgroundParams.scale;

  void setDashboardPosition(Offset position) {
    _dashboardPosition = position;
  }

  Offset get position => _dashboardPosition;

  void setDashboardSize(Size size) {
    dashboardSize = size;
  }

  void addNextById(
    T sourceElement,
    String destId,
    ArrowParams arrowParams, {
    bool notify = true,
  }) {
    var found = 0;
    arrowParams.setScale(1, gridBackgroundParams.scale);
    for (final element in elements) {
      if (element.id == destId) {
        sourceElement.next
            .removeWhere((element) => element.destElementId == destId);
        final conn = ConnectionParams(
          destElementId: element.id,
          arrowParams: arrowParams,
          pivots: [],
        );
        sourceElement.next.add(conn);
        for (final listener in _connectionListeners) {
          listener(sourceElement, element);
        }
        found++;
      }
    }

    if (found == 0) {
      debugPrint('Element with $destId id not found!');
      return;
    }
    if (notify) {
      notifyListeners();
    }
  }

  void recenter() {
    final center = Offset(dashboardSize.width / 2, dashboardSize.height / 2);
    gridBackgroundParams.offset = center;
    if (elements.isNotEmpty) {
      final currentDeviation = elements.first.position - center;
      for (final element in elements) {
        element.position -= currentDeviation;
        for (final next in element.next) {
          for (final pivot in next.pivots) {
            pivot.pivot -= currentDeviation;
          }
        }
      }
    }
    notifyListeners();
  }
}
