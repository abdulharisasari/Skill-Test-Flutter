import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  static const String _attendanceHistoryKey = 'attendance_history';
  static const String _todayAttendanceKey = 'today_attendance';
  static const String _officeSettingsKey = 'office_settings';
  static const String _todayCheckoutKey = 'today_checkout';
  
  Future<void> saveCheckout(AttendanceModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('today_checkout', jsonEncode(model.toJson()));
  }

  Future<AttendanceModel?> getTodayCheckout() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_todayCheckoutKey);
    if (jsonString != null) {
      return AttendanceModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  Future<void> saveAttendance(AttendanceModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_attendanceHistoryKey) ?? [];
    jsonList.add(json.encode(model.toJson()));
    await prefs.setStringList(_attendanceHistoryKey, jsonList);
    await prefs.setString(_todayAttendanceKey, json.encode(model.toJson()));
  }

  Future<List<AttendanceModel>> getAttendanceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_attendanceHistoryKey) ?? [];
    return jsonList.map((jsonStr) => AttendanceModel.fromJson(json.decode(jsonStr))).toList();
  }

  Future<void> deleteAttendance(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_attendanceHistoryKey) ?? [];
    if (index >= 0 && index < jsonList.length) {
      jsonList.removeAt(index);
      await prefs.setStringList(_attendanceHistoryKey, jsonList);
    }
  }

  Future<AttendanceModel?> getTodayAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_todayAttendanceKey);
    if (jsonString != null) {
      return AttendanceModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  Future<void> saveOfficeSettings(double lat, double lng, double radius) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    };
    await prefs.setString(_officeSettingsKey, jsonEncode(settings));
  }

  Future<Map<String, dynamic>?> getOfficeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_officeSettingsKey);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }
}
