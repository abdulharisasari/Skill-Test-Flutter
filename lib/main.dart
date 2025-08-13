import 'package:absensi/screens/admin/history/index.dart';
import 'package:absensi/screens/admin/home/index.dart';
import 'package:absensi/screens/admin/location-office/index.dart';
import 'package:absensi/screens/auth/login/index.dart';
import 'package:absensi/screens/user/history/index.dart';
import 'package:absensi/screens/user/home/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/office_config_provider.dart';
import 'screens/user/attendance/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthProvider();
  await auth.loadUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => auth),
         ChangeNotifierProvider(create: (_) => OfficeConfigProvider()),
         ChangeNotifierProxyProvider<OfficeConfigProvider, AttendanceProvider>(
          create: (context) => AttendanceProvider(
            officeConfig: context.read<OfficeConfigProvider>(),
          ),
          update: (context, officeConfig, previous) => AttendanceProvider(officeConfig: officeConfig),
        ),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/admin-home': (_) => const AdminHomeScreen(),
        '/user-home': (_) => const UserHomeScreen(),
        '/office-config': (_) => const OfficeConfigScreen(),
        '/attendance': (_) => const AttendanceScreen(),
        '/admin-history': (_) => const AdminUserListScreen(),
        '/attendance-history': (_) => const AttendanceHistoryScreen(),

      },
    );
  }
}
