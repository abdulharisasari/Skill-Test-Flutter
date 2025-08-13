import 'package:absensi/providers/attendance_provider.dart';
import 'package:absensi/providers/auth_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with WidgetsBindingObserver {
  bool _loadingLocation = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _refreshAttendance();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAttendance();
    }
  }

  Future<void> _refreshAttendance() async {
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);
    setState(() => _loadingLocation = true);

    await attendance.fetchTodayAttendance();

    await attendance.getCurrentLocation();

    setState(() => _loadingLocation = false);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      print("❌ Gagal inisialisasi kamera: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context);

    final today = DateTime.now();
    final dateStr = "${today.day}-${today.month}-${today.year} ${today.hour}:${today.minute}:${today.second}";
    final alreadyCheckedIn = attendance.todayAttendance != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loadingLocation
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: ${auth.user?.email ?? "-"}'),
                  Text('Waktu: $dateStr'),
                  Text('Lokasi: ${attendance.address ?? "Mengambil lokasi..."}'),
                  const SizedBox(height: 8),
                  Text(
                    'Status hari ini: ${alreadyCheckedIn ? "Sudah Absen" : "Belum Absen"}',
                    style: TextStyle(
                      color: alreadyCheckedIn ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: attendance.selfie != null ? Image.file(attendance.selfie!, fit: BoxFit.cover) : (_cameraController != null && _cameraController!.value.isInitialized ? CameraPreview(_cameraController!) : const Center(child: Text('Tidak bisa mengakses kamera'))),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_cameraController != null) {
                            await attendance.takeSelfieWithCamera(_cameraController!);
                          }
                        },
                        child: const Text('Ambil Selfie'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: alreadyCheckedIn || !attendance.isWithinOffice || attendance.selfie == null
                            ? null
                            : () async {
                                await attendance.markAttendance(auth.user?.email ?? "-");
                              },
                        child: const Text('Absen Sekarang'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!attendance.isWithinOffice)
                    const Text(
                      'Anda berada di luar radius 100 meter dari kantor',
                      style: TextStyle(color: Colors.orange),
                    ),
                ],
              ),
      ),
    );
  }
}
