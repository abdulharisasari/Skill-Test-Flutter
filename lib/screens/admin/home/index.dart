import 'package:absensi/providers/auth_provider.dart';
import 'package:absensi/screens/auth/login/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});


  Future<void> _logout(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/office-config'),
            child: const Text('Pengaturan Lokasi Kantor'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/admin-history'),
            child: const Text('Lihat History Absensi'),
          ),
        ],
      ),
    );
  }
}
