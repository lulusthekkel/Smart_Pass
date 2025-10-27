import 'package:flutter/material.dart';

class WardenDashboard extends StatelessWidget {
  const WardenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warden Dashboard')),
      body: const Center(child: Text('Welcome, Warden!')),
    );
  }
}
