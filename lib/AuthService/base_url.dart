import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    // Check if running on an emulator or real device
    if (Platform.isAndroid || Platform.isIOS) {
      // If it's an emulator, use the special address
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080'; // For Android Emulator
      } else if (Platform.isIOS) {
        return 'http://localhost:8080'; // For iOS Simulator
      }
    } else {
      // If it's a real device, use the local network IP
      return 'http://192.168.1.217:8080'; // For real devices on local network
    }
    return 'http://localhost:8080'; // Default fallback
  }
}
