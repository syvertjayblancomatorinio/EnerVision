import 'dart:io' as io;
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Environment check for production vs development
    const bool isProduction = bool.fromEnvironment('dart.vm.product');

    if (isProduction) {
      // Use the production API URL
      return 'https://api.production.com';
    } else {
      // Development environment
      // Check if running on an emulator, real device, or web
      if (kIsWeb) {
        // If it's a web platform, use a different base URL
        return 'http://localhost:8080'; // For Web
      } else if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
        // If it's an emulator or real device
        if (io.Platform.isAndroid) {
          return 'http://10.0.2.2:8080'; // For Android Emulator
        } else if (io.Platform.isIOS) {
          return 'http://localhost:8080'; // For iOS Simulator
        }
      } else if (!kIsWeb) {
        // For physical devices or other platforms like macOS, Linux, or Windows
        return 'http://192.168.1.217:8080'; // Replace with your local network IP
      }

      // Default fallback for unknown platforms
      debugPrint('Unknown platform detected, falling back to localhost.');
      return 'http://localhost:8080';
    }
  }
}
