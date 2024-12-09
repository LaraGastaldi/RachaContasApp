import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static Future<String> get(String key) async {
    return await dotenv.load(fileName: '.env').then((value) =>
    dotenv.env[key] ?? '');
  }
}