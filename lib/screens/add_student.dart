import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final rollController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final batchController = TextEditingController();
  final parentIdController = TextEditingController();

  Future<void> addStudent() async {
    if (_formKey.currentState!.validate()) {
      final response = await supabase.from('students').insert({
        'name': nameController.text,
        'roll_no': rollController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'batch': batchController.text,
        'class_advisor_id': 'advisor-id-uuid', // replace with actual advisor ID
        'parent_id': parentIdController.text,
        'password': 'pass123', // temp password
      });

      if (response.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response.error!.message)));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Student added successfully')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'Enter name' : null),
              TextFormField(controller: rollController, decoration: const InputDecoration(labelText: 'Roll No'), validator: (v) => v!.isEmpty ? 'Enter roll no' : null),
              TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Enter email' : null),
              TextFormField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextFormField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
              TextFormField(controller: batchController, decoration: const InputDecoration(labelText: 'Batch')),
              TextFormField(controller: parentIdController, decoration: const InputDecoration(labelText: 'Parent ID')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: addStudent, child: const Text('Add Student')),
            ],
          ),
        ),
      ),
    );
  }
}
