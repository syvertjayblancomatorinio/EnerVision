import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Check if running on an emulator, real device, or web
    if (kIsWeb) {
      // Web app uses public URL
      return 'https://enervisionpn.netlify.app/'; // Replace with your actual API URL
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // For Android Emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8080'; // For iOS Simulator
    } else {
      return 'http://192.168.1.217:8080'; // For real devices on local network
    }
    return 'http://localhost:8080'; // Default fallback
  }
}
