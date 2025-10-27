import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/edit_student.dart';
import '../screens/bulk_add_students.dart';

final supabase = Supabase.instance.client;

class ClassAdvisorPage extends StatefulWidget {
  final String batch; // selected batch
  final String advisorId; // logged-in advisor's ID

  const ClassAdvisorPage({super.key, required this.batch, required this.advisorId});

  @override
  State<ClassAdvisorPage> createState() => _ClassAdvisorPageState();
}

class _ClassAdvisorPageState extends State<ClassAdvisorPage> {
  List<dynamic> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase.from('students').select().eq('batch', widget.batch);
      setState(() {
        students = data;
      });
    } catch (error) {
      print('Error fetching students: $error');
    }
    setState(() => isLoading = false);
  }

  Future<void> addStudentDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final parentNameController = TextEditingController();
    final parentPhoneController = TextEditingController();
    final parentAddressController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: parentNameController, decoration: const InputDecoration(labelText: 'Parent Name')),
            TextField(controller: parentPhoneController, decoration: const InputDecoration(labelText: 'Parent Phone')),
            TextField(controller: parentAddressController, decoration: const InputDecoration(labelText: 'Parent Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              // Add parent first
              final parentInsert = await supabase.from('parents').insert({
                'name': parentNameController.text.trim(),
                'phone': parentPhoneController.text.trim(),
                'address': parentAddressController.text.trim(),
              }).select('id').single();

              final parentId = parentInsert['id'];

              // Add student
              await supabase.from('students').insert({
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
                'parent_id': parentId,
                'parent_address': parentAddressController.text.trim(),
                'batch': widget.batch,
                'class_advisor_id': widget.advisorId,
              });

              Navigator.pop(context);
              fetchStudents();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteStudent(String id) async {
    try {
      await supabase.from('students').delete().eq('id', id);
      fetchStudents();
    } catch (error) {
      print('Error deleting student: $error');
    }
  }

 // Navigate to bulk upload and refresh after completion
  Future<void> goToBulkUpload() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BulkAddStudentPage(batch: widget.batch, advisorId: widget.advisorId),
      ),
    );
    // Refresh the list automatically after returning from bulk upload
    fetchStudents();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch ${widget.batch} Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Bulk Upload',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BulkAddStudentPage(batch: widget.batch, advisorId: widget.advisorId),
                ),
              );

              if (result == true) {
                fetchStudents();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Students list updated after bulk upload')),
                );
              }
            },
          ),
          IconButton(icon: const Icon(Icons.add), tooltip: 'Add Student', onPressed: addStudentDialog),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(child: Text('No students found.'))
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(student['name'] ?? ''),
                        subtitle: Text('Phone: ${student['phone']} | Parent Addr: ${student['parent_address']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => EditStudent(student: student)),
                                );
                                fetchStudents();
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
