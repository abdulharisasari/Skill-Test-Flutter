import 'dart:io';

import 'package:absensi/models/user_model.dart';
import 'package:absensi/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../models/attendance_model.dart';


class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _loading = true);

      final storage = LocalStorageService();
      final users = await storage.getUserList();

      setState(() {
        _users = users;
        _loading = false;
      });

    } catch (e) {
      setState(() => _loading = false);

      print("Gagal memuat data user: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar User')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('Belum ada user terdaftar'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      title: Text(user.email),
                      subtitle: Text('Role: ${user.role}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserHistoryDetailScreen(email: user.email),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}


class UserHistoryDetailScreen extends StatefulWidget {
  final String email;
  const UserHistoryDetailScreen({super.key, required this.email});

  @override
  State<UserHistoryDetailScreen> createState() => _UserHistoryDetailScreenState();
}

class _UserHistoryDetailScreenState extends State<UserHistoryDetailScreen> {
  List<AttendanceModel> _userHistory = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserHistory();
  }

  Future<void> _loadUserHistory() async {
    setState(() => _loading = true);
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final all = await provider.getAttendanceHistory();
    _userHistory = all.where((e) => e.email == widget.email).toList();
    setState(() => _loading = false);
  }

  Future<void> _deleteAttendance(int index) async {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Absensi'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await provider.deleteAttendanceByEmail(widget.email, index);
      _loadUserHistory(); 
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Absensi: ${widget.email}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userHistory.isEmpty
              ? const Center(child: Text('Belum ada data absensi'))
              : ListView.builder(
                  itemCount: _userHistory.length,
                  itemBuilder: (context, index) {
                    final item = _userHistory[index];
                    return ListTile(
                      leading: item.selfiePath != null
                          ? Image.file(
                              File(item.selfiePath!),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text('${item.date} ${item.time}'),
                      subtitle: Text(item.location),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAttendance(index),
                      ),
                    );
                  },
                ),
    );
  }
}
