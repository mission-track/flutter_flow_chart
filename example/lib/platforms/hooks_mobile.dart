import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Save dashboard to file
Future<void> saveDashboard(Dashboard dashboard) async {
  final appDocDir = await path.getApplicationDocumentsDirectory();
  dashboard.saveDashboard('${appDocDir.path}/FLOWCHART.json');
}

/// Load dashboard from file
Future<void> loadDashboard(Dashboard dashboard) async {
  final appDocDir = await path.getApplicationDocumentsDirectory();
  dashboard.loadDashboard('${appDocDir.path}/FLOWCHART.json');
}

/// Pick image
Future<Uint8List?> pickImageBytes() async {
  final pickResult = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );
  if (pickResult == null) return null;
  return File(pickResult.files.single.path!).readAsBytesSync();
}

/// Load image from URL
Future<ui.Image?> loadImageFromUrl(String url) async {
  try {
    // Download the image
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      print('Failed to load image: HTTP ${response.statusCode}');
      return null;
    }
    
    // Decode the image
    final Uint8List bytes = response.bodyBytes;
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      print('Error decoding image: $e');
      return null;
    }
  } catch (e) {
    print('Error loading image from URL: $e');
    return null;
  }
}
