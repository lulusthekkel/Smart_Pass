import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/edit_student.dart'; 

final supabase = Supabase.instance.client;

class ClassAdvisorPage extends StatefulWidget {
  const ClassAdvisorPage({super.key});

  @override
  State<ClassAdvisorPage> createState() => _ClassAdvisorPageState();
}

class _ClassAdvisorPageState extends State<ClassAdvisorPage> {
  List<dynamic> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final data = await supabase.from('students').select();
      setState(() {
        students = data;
      });
    } catch (error) {
      print('Error fetching students: $error');
    }
  }

  Future<void> addStudentDialog() async {
    final nameController = TextEditingController();
    final rollController = TextEditingController();
    final deptController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: rollController, decoration: const InputDecoration(labelText: 'Roll Number')),
            TextField(controller: deptController, decoration: const InputDecoration(labelText: 'Department')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await addStudent(
                nameController.text,
                int.tryParse(rollController.text) ?? 0,
                deptController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> addStudent(String name, int rollNumber, String department) async {
    try {
      await supabase.from('students').insert({
        'name': name,
        'roll_number': rollNumber,
        'department': department,
      });
      fetchStudents(); // refresh
    } catch (error) {
      print('Error adding student: $error');
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await supabase.from('students').delete().eq('id', id);
      fetchStudents();
    } catch (error) {
      print('Error deleting student: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Advisor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addStudentDialog,
          ),
        ],
      ),
      body: students.isEmpty
          ? const Center(child: Text('No students found.'))
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(student['name'] ?? ''),
                    subtitle: Text('Dept: ${student['department']} | Roll: ${student['roll_number']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditStudent(student: student),
                              ),
                            );
                            fetchStudents(); // refresh after edit
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteStudent(student['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
