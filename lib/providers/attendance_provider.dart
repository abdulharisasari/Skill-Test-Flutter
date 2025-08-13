import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';
import 'office_config_provider.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();
  final OfficeConfigProvider officeConfig;

  AttendanceProvider({required this.officeConfig});

  AttendanceModel? _todayAttendance;
  String? _address;
  Position? _position;
  File? _selfie;

  AttendanceModel? get todayAttendance => _todayAttendance;
  String? get address => _address;
  Position? get position => _position;
  File? get selfie => _selfie;

  Future<AttendanceModel?> fetchTodayAttendance() async {
    await loadTodayAttendance(); 
    return _todayAttendance;
  }

  bool get isWithinOffice {
    if (_position == null) return false;
    final distance = Geolocator.distanceBetween(
      _position!.latitude,
      _position!.longitude,
      officeConfig.lat,
      officeConfig.lng,
    );
    return distance <= officeConfig.radius;
  }
 
 
   void setSelfie(File file) {
    _selfie = file;
    notifyListeners();
  }

  Future<void> takeSelfieWithCamera(CameraController controller) async {
    if (controller.value.isInitialized) {
      final xFile = await controller.takePicture();
      _selfie = File(xFile.path);
      notifyListeners();
    }
  }

  Future<void> loadTodayAttendance() async {
    await officeConfig.loadSettings();
    final saved = await _service.getTodayAttendance();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todayAttendance = (saved != null && saved.date == todayStr) ? saved : null;
    notifyListeners();
  }


  Future<List<AttendanceModel>> getAttendanceHistory() async {
    return await _service.getAttendanceHistory();
  }
  
  Future<List<AttendanceModel>> getUserAttendanceHistory(String email) async {
    final all = await _service.getAttendanceHistory();
    return all.where((item) => item.email == email).toList();
  }

  Future<List<AttendanceModel>> getAllAttendanceHistory() async {
    return await _service.getAttendanceHistory();
  }








  
  Future<void> deleteAttendanceByEmail(String email, int filteredIndex) async {
    try {
      final allHistory = await _service.getAttendanceHistory();

    
      final userHistory = allHistory.where((e) => e.email == email).toList();

    
      if (filteredIndex >= 0 && filteredIndex < userHistory.length) {
      
        final target = userHistory[filteredIndex];

      
        final realIndex = allHistory.indexWhere((e) => e.email == target.email && e.date == target.date);

        if (realIndex != -1) {
          await _service.deleteAttendance(realIndex);
          notifyListeners();
          print("✅ Absensi untuk $email berhasil dihapus.");
        } else {
          print("⚠️ Data absensi tidak ditemukan di storage.");
        }
      }
    } catch (e, s) {
      print("❌ Error saat menghapus absensi: $e");
      print(s);
    }
  }

  Future<void> getCurrentLocation() async {
    await officeConfig.loadSettings();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Lokasi tidak diizinkan');
    }

    _position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    final placemarks = await placemarkFromCoordinates(
      _position!.latitude,
      _position!.longitude,
    );

    _address = placemarks.isNotEmpty ? "${placemarks.first.street}, ${placemarks.first.locality}" : "${_position!.latitude}, ${_position!.longitude}";
    notifyListeners();
  }

  Future<void> takeSelfie() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _selfie = File(image.path);
      notifyListeners();
    }
  }
  Future<void> markAttendance(String userEmail) async {
    await officeConfig.loadSettings();
    if (!isWithinOffice || _selfie == null) return;

    final now = DateTime.now();
    final model = AttendanceModel(
      email: userEmail,
      date: DateFormat('yyyy-MM-dd').format(now),
      time: DateFormat('HH:mm:ss').format(now),
      location: _address ?? '',
      coordinates: "${_position!.latitude}, ${_position!.longitude}",
      selfiePath: _selfie!.path,
    );

    await _service.saveAttendance(model);
    _todayAttendance = model;
    notifyListeners();
  }
}
