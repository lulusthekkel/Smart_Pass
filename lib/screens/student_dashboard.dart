import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? student;
  List<Map<String, dynamic>> passes = [];
  bool isLoading = true;
  StreamSubscription<dynamic>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    student = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    fetchPasses();

    if (student != null) {
      _subscription = supabase
          .from('passes')
          .stream(primaryKey: ['id'])
          .eq('student_id', student!['id'])
          .order('created_at', ascending: false)
          .listen((data) {
        setState(() {
          passes = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }, onError: (_) {
        fetchPasses();
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> fetchPasses() async {
    if (student == null) return;
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('passes')
          .select()
          .eq('student_id', student!['id'])
          .order('created_at', ascending: false);

      setState(() {
        passes = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> submitPassRequest() async {
    final typeController = TextEditingController();
    final reasonController = TextEditingController();
    final fromDateController = TextEditingController();
    final toDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request Pass'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                items: const [
                  DropdownMenuItem(value: 'Leave', child: Text('Leave')),
                  DropdownMenuItem(value: 'Gate', child: Text('Gate Pass')),
                ],
                onChanged: (value) => typeController.text = value ?? '',
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fromDateController,
                decoration: const InputDecoration(labelText: 'From Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    fromDateController.text = picked.toIso8601String().split('T')[0];
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: toDateController,
                decoration: const InputDecoration(labelText: 'To Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    toDateController.text = picked.toIso8601String().split('T')[0];
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (typeController.text.isEmpty ||
                  fromDateController.text.isEmpty ||
                  toDateController.text.isEmpty) return;

              try {
                await supabase.from('passes').insert({
                  'student_id': student!['id'],
                  'type': typeController.text,
                  'reason': reasonController.text,
                  'from_date': fromDateController.text,
                  'to_date': toDateController.text,
                  'approved_by_advisor': false,
                  'approved_by_hod': false,
                  'approved_by_warden': false,
                });

                Navigator.pop(context);
                fetchPasses(); // refresh list after insert
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error submitting pass: $e')));
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    // Dispose controllers after dialog is closed
    typeController.dispose();
    reasonController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
  }

  void logout() async {
    await supabase.auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${student?['name'] ?? 'Student'}'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Request Pass'),
                    onPressed: submitPassRequest,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: passes.isEmpty
                        ? const Center(child: Text('No pass requests yet'))
                        : ListView.builder(
                            itemCount: passes.length,
                            itemBuilder: (context, index) {
                              final pass = passes[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text('${pass['type']}'),
                                  subtitle: Text(
                                    'Reason: ${pass['reason'] ?? '-'}\n'
                                    'From: ${pass['from_date']} To: ${pass['to_date']}\n'
                                    'Advisor: ${pass['approved_by_advisor']} | '
                                    'HOD: ${pass['approved_by_hod']} | '
                                    'Warden: ${pass['approved_by_warden']}',
                                  ),
                                  trailing: Text(
                                    '${DateTime.parse(pass['created_at']).toLocal()}'
                                        .split('.')[0],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
