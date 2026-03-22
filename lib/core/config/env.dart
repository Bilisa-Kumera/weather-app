import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
}
