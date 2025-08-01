import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pose_session.dart';

class PoseLoader {
  static Future<PoseSession> loadPoseSession() async {
    final jsonData = await rootBundle.loadString('assets/poses.json');
    final Map<String, dynamic> parsedJson = json.decode(jsonData);
    return PoseSession.fromJson(parsedJson);
  }
}
