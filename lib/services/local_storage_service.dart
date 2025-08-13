import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _keyUser = 'user_data';
  static const String _keyUserList = 'user_list';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUser);
    if (data != null) {
      return UserModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  Future<void> addUserToList(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyUserList) ?? [];
    list.add(jsonEncode(user.toJson()));
    await prefs.setStringList(_keyUserList, list);
  }

  Future<List<UserModel>> getUserList() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyUserList) ?? [];
    return list.map((e) => UserModel.fromJson(jsonDecode(e))).toList();
  }
}
