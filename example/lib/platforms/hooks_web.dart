import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:web/web.dart' as web;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Save dashboard to file
Future<void> saveDashboard(Dashboard dashboard) async {
  final bytes = utf8.encode(dashboard.prettyJson());
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = 'data:application/octet-stream;base64,${base64Encode(bytes)}'
    ..style.display = 'none'
    ..download = 'FLOWCHART.json';
  web.document.body!.appendChild(anchor);
  anchor.click();
  web.document.body!.removeChild(anchor);
}

/// Load dashboard from file
Future<void> loadDashboard(Dashboard dashboard) async {
  final result = await FilePicker.platform.pickFiles();
  if (result == null) return;
  dashboard.loadDashboardData(
    jsonDecode(String.fromCharCodes(result.files.first.bytes!))
        as Map<String, dynamic>,
  );
}

Future<Uint8List?> pickImageBytes() async {
  final pickResult = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );
  if (pickResult == null) return null;
  return pickResult.files.single.bytes;
}

/// Load image from URL
Future<ImageProvider?> loadImageFromUrl(String url) async {
  try {
    // Create an HTML image element
    final imageElement = html.ImageElement();
    final completer = Completer<ImageProvider?>();
    
    // Set up load event handler before setting src
    imageElement.onLoad.listen((event) async {
      try {
        // Check if dimensions are valid
        if (imageElement.naturalWidth == 0 || imageElement.naturalHeight == 0) {
          print('Invalid image dimensions: ${imageElement.naturalWidth}x${imageElement.naturalHeight}');
          completer.complete(null);
          return;
        }
        
        // Convert the image element to a canvas
        final canvas = html.CanvasElement(
          width: imageElement.naturalWidth,
          height: imageElement.naturalHeight,
        );
        
        final context = canvas.context2D;
        context.drawImage(imageElement, 0, 0);
        
        try {
          // Get the image data as base64
          final dataUrl = canvas.toDataUrl('image/png');
          final base64 = dataUrl.split(',')[1];
          final bytes = base64Decode(base64);
          
          // Create a MemoryImage from the bytes
          completer.complete(MemoryImage(bytes));
          print('Image loaded successfully');
        } catch (e) {
          print('Error processing canvas data: $e');
          completer.complete(null);
        }
      } catch (e) {
        print('Error in onLoad handler: $e');
        completer.complete(null);
      }
    });
    
    // Handle errors
    imageElement.onError.listen((event) {
      print('Error loading image from URL: $event');
      completer.complete(null);
    });
    
    // Set crossOrigin before src
    imageElement.crossOrigin = 'anonymous';
    imageElement.src = url;
    
    // Set a timeout in case the image loading hangs
    Future.delayed(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        print('Image loading timed out');
        completer.complete(null);
      }
    });
    
    return completer.future;
  } catch (e) {
    print('Error in loadImageFromUrl: $e');
    return null;
  }
}
