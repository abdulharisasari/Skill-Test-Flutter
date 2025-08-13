import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/attendance_service.dart';

class OfficeConfigProvider extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();

  double _lat = -6.200000;
  double _lng = 106.816666;
  double _radius = 100; // meter

  double get lat => _lat;
  double get lng => _lng;
  double get radius => _radius;

  Future<void> loadSettings() async {
    final settings = await _service.getOfficeSettings();
    if (settings != null) {
      _lat = settings['lat'] ?? _lat;
      _lng = settings['lng'] ?? _lng;
      _radius = settings['radius'] ?? _radius;
      notifyListeners();
    }
  }

  Future<void> updateConfig(double lat, double lng, double radius) async {
    _lat = lat;
    _lng = lng;
    _radius = radius;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('office_lat', lat);
    await prefs.setDouble('office_lng', lng);
    await prefs.setDouble('office_radius', radius);

    notifyListeners();
  }

  Future<void> updateSettings({
    required double lat,
    required double lng,
    required double radius,
  }) async {
    _lat = lat;
    _lng = lng;
    _radius = radius;
    await _service.saveOfficeSettings(lat, lng, radius);
    notifyListeners();
  }
}
