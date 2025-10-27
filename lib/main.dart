import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_page.dart';
import '../screens/advisor_dashboard.dart';
import '../screens/hod_dashboard.dart';
import '../screens/warden_dashboard.dart';
import '../screens/student_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vvrlraqbwdjplgknjmso.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2cmxyYXFid2RqcGxna25qbXNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3MjM3MDYsImV4cCI6MjA3NjI5OTcwNn0.KdLlAllDqpy_sT_iKBVhdLgwpL6h_nWlWSnwGk0dXPg', // paste your anon public key
  );

  runApp(const SmartPassApp());
}

class SmartPassApp extends StatelessWidget {
  const SmartPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPass Login',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/': (_) => const LoginPage(),
        '/student_dashboard': (_) => const StudentDashboard(),
        '/advisor_dashboard': (_) => const AdvisorDashboard(),
        '/hod_dashboard': (_) => const HodDashboard(),
        '/warden_dashboard': (_) => const WardenDashboard(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartPass Home')),
      body: const Center(child: Text('Supabase Connected Successfully!')),
    );
  }
}
