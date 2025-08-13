import 'package:absensi/providers/auth_provider.dart';
import 'package:absensi/screens/auth/login/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});
  
  
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
        title: const Text('User Home'),
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
            onPressed: () => Navigator.pushNamed(context, '/attendance'),
            child: const Text('Absen Sekarang'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/attendance-history'),
            child: const Text('Lihat History Absensi'),
          ),
        ],
      ),
    );
  }
}
