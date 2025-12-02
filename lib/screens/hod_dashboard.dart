import 'package:flutter/material.dart';

class HodDashboard extends StatelessWidget {
  const HodDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HOD Dashboard')),
      body: const Center(child: Text('Welcome, HOD!')),
    );
  }
}
