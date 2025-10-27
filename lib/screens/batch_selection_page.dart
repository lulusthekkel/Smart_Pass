import 'package:flutter/material.dart';
import '../widgets/class_advisor_page.dart';

class BatchSelectionPage extends StatelessWidget {
  const BatchSelectionPage({super.key});

  final List<String> batches = const ['2022', '2023', '2024', '2025', '2026'];

  @override
  Widget build(BuildContext context) {
    // Get logged-in advisor's ID from Supabase Auth
    final loggedInAdvisorId = '21a59f33-98dd-4b99-8150-f029c53d0488' ;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Batch')),
      body: ListView.builder(
        itemCount: batches.length,
        itemBuilder: (context, index) {
          final batch = batches[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('Batch $batch'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClassAdvisorPage(
                      batch: batch,
                      advisorId: loggedInAdvisorId, // pass advisor ID here
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
