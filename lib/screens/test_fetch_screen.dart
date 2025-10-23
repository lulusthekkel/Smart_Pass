import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestFetchScreen extends StatefulWidget {
  const TestFetchScreen({super.key});

  @override
  _TestFetchScreenState createState() => _TestFetchScreenState();
}

class _TestFetchScreenState extends State<TestFetchScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
  try {
    final response = await supabase.from('students').select();

    setState(() {
      students = response as List<dynamic>;
    });

    print('Students fetched successfully');
  } catch (error) {
    print('Error fetching students: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Fetch Students')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            title: Text(student['name'] ?? 'No Name'),
            subtitle: Text(student['roll_no'] ?? 'No Roll No'),
          );
        },
      ),
    );
  }
}
