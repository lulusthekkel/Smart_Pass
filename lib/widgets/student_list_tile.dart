import 'package:flutter/material.dart';

class StudentListTile extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onEdit;

  const StudentListTile({super.key, required this.student, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(student['name'] ?? 'No Name'),
        subtitle: Text('Roll: ${student['roll_no'] ?? 'N/A'}\nPhone: ${student['phone'] ?? 'N/A'}'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
