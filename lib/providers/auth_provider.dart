import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';



class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  final LocalStorageService _storage = LocalStorageService();

  Future<bool> login(String email, String password) async {
    final users = await _storage.getUserList();
    try {
      final found = users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _user = found;
      await _storage.saveUser(_user!);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }


  Future<void> logout() async {
    _user = null;
    await _storage.clearUser();
    notifyListeners();
  }

  Future<void> loadUser() async {
    _user = await _storage.getUser();
    notifyListeners();
  }
}
