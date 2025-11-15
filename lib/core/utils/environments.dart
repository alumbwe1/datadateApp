import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static var apiBaseUrl;

  static String get fileName {
    if (kReleaseMode) {
      return '.env.production';
    }

    return '.env.development';
  }

  static String get apiKey => dotenv.env['API_KEY'] ?? 'API_KEY not found';

  static String get apiVersion =>
      dotenv.env['API_VERSION'] ?? 'API_VERSION not found';
  static String get imageBaseUrl =>
      dotenv.env['IMAGE_BASE_URL'] ?? 'IMAGE_BASE_URL not found';

  static String get airtelClientId =>
      dotenv.env['AIRTEL_CLIENT_ID'] ?? 'AIRTEL_CLIENT_ID not found';

  static String get airtelClientSecret =>
      dotenv.env['AIRTEL_CLIENT_SECRET'] ?? 'AIRTEL_CLIENT_SECRET not found';

  static String get airtelBaseUrl =>
      dotenv.env['AIRTEL_BASE_URL'] ?? 'AIRTEL_BASE_URL not found';

  static String get airtelPaymentUrl =>
      dotenv.env['AIRTEL_PAYMENT_URL'] ?? 'AIRTEL_PAYMENT_URL not found';

  static String get airtelAuthUrl =>
      dotenv.env['AIRTEL_AUTH_URL'] ?? 'AIRTEL_AUTH_URL not found';

  static String get appBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'API_BASE_URL not found';

  static String get googleApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'GOOGLE_MAPS_API_KEY not found';
}
