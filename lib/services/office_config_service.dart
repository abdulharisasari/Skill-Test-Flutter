import 'package:shared_preferences/shared_preferences.dart';

class OfficeConfigService {
  static const String _latKey = 'office_lat';
  static const String _lngKey = 'office_lng';
  static const String _radiusKey = 'office_radius';

  Future<void> saveConfig(double lat, double lng, double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);
    await prefs.setDouble(_radiusKey, radius);
  }

  Future<Map<String, double>> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'lat': prefs.getDouble(_latKey) ?? -6.200000,
      'lng': prefs.getDouble(_lngKey) ?? 106.816666,
      'radius': prefs.getDouble(_radiusKey) ?? 100,
    };
  }
}
