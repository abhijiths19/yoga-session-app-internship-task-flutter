import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pose_session.dart';

class JsonLoader {
  static Future<PoseSession> loadSessionFromJson(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final jsonData = json.decode(jsonString);
    return PoseSession.fromJson(jsonData);
  }
}
