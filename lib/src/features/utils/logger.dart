// lib/utils/logger.dart
class Logger {
  static bool isInDebugMode = false; // Set this to true for debug builds

  static void log(String message) {
    if (isInDebugMode) {
      Logger.log(message);
    }
  }
}
