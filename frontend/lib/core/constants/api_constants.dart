import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Notes endpoints
  static const String notes = '/notes';
  static String noteById(String id) => '/notes/$id';
}
