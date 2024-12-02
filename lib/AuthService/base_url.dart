import 'dart:io' as io;
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Check if running on an emulator, real device, or web
    if (kIsWeb) {
      // If it's a web platform, use a different base URL
      return 'http://localhost:8080'; // For Web
    } else if (io.Platform.isAndroid || io.Platform.isIOS) {
      // If it's an emulator or real device
      if (io.Platform.isAndroid) {
        return 'http://10.0.2.2:8080'; // For Android Emulator
      } else if (io.Platform.isIOS) {
        return 'http://localhost:8080'; // For iOS Simulator
      }
    } else {
      // For real devices on local network (other platforms like macOS, Linux, etc.)
      return 'http://192.168.1.217:8080'; // Local network IP
    }
    return 'http://localhost:8080'; // Default fallback
  }
}
