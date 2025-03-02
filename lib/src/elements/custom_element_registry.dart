import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';

/// Type definition for a custom element widget builder
typedef CustomElementWidgetBuilder = Widget Function(FlowElement element);

/// Registry for custom element widgets
class CustomElementRegistry {
  /// Private constructor for singleton pattern
  CustomElementRegistry._();

  /// Singleton instance
  static final CustomElementRegistry instance = CustomElementRegistry._();

  /// Map of custom element type identifiers to their widget builders
  final Map<String, CustomElementWidgetBuilder> _registry = {};

  /// Register a custom element widget builder with a unique identifier
  void register(String customElementType, CustomElementWidgetBuilder builder) {
    if (_registry.containsKey(customElementType)) {
      debugPrint('Warning: Overwriting existing custom element type: $customElementType');
    }
    _registry[customElementType] = builder;
  }

  /// Unregister a custom element widget builder
  void unregister(String customElementType) {
    _registry.remove(customElementType);
  }

  /// Get a custom element widget builder by its identifier
  CustomElementWidgetBuilder? getBuilder(String? customElementType) {
    if (customElementType == null) return null;
    return _registry[customElementType];
  }

  /// Check if a custom element type is registered
  bool isRegistered(String customElementType) {
    return _registry.containsKey(customElementType);
  }

  /// Get all registered custom element types
  List<String> get registeredTypes => _registry.keys.toList();
}
