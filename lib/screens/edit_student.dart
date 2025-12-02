import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class EditStudent extends StatefulWidget {
  final Map<String, dynamic> student;
  const EditStudent({required this.student, super.key});

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  late TextEditingController nameController;
  late TextEditingController deptController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student['name']);
    deptController = TextEditingController(text: widget.student['department']);
  }

  Future<void> updateStudent() async {
    try {
      await supabase
          .from('students')
          .update({
            'name': nameController.text,
            'department': deptController.text,
          })
          .eq('id', widget.student['id']);
      Navigator.pop(context);
    } catch (error) {
      print('Error updating student: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Student')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: deptController, decoration: const InputDecoration(labelText: 'Department')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: updateStudent, child: const Text('Update')),
          ],
        ),
      ),
    );
  }
}
