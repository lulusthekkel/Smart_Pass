import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BulkAddStudentPage extends StatefulWidget {
  final String batch; // Selected batch
  final String advisorId; // Current logged-in advisor ID

  const BulkAddStudentPage({Key? key, required this.batch, required this.advisorId}) : super(key: key);

  @override
  _BulkAddStudentPageState createState() => _BulkAddStudentPageState();
}

class _BulkAddStudentPageState extends State<BulkAddStudentPage> {
  bool isUploading = false;
  String message = '';

  final supabase = Supabase.instance.client;

  Future<void> _pickAndUploadCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => message = '❌ No file selected.');
        return;
      }

      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) {
        setState(() => message = '❌ File has no data.');
        return;
      }

      setState(() {
        isUploading = true;
        message = '⏳ Uploading...';
      });

      // Decode CSV
      String csvString;
      try {
        csvString = utf8.decode(fileBytes);
      } catch (e) {
        csvString = latin1.decode(fileBytes);
      }

      final rows = const CsvToListConverter().convert(csvString);

      if (rows.length < 2) {
        setState(() => message = '⚠️ CSV has no student data.');
        return;
      }

      final headers = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
      final dataRows = rows.skip(1);

      int insertedCount = 0;

      for (final row in dataRows) {
        final studentMap = <String, dynamic>{};

        for (int i = 0; i < headers.length && i < row.length; i++) {
          studentMap[headers[i]] = row[i].toString().trim();
        }

        final studentName = studentMap['name'] ?? '';
        final studentPhone = studentMap['phone'] ?? '';
        final parentName = studentMap['parent_name'] ?? '';
        final parentPhone = studentMap['parent_phone'] ?? '';
        final parentAddress = studentMap['parent_address'] ?? '';

        // Find parent in DB
        final parentResponse = await supabase
            .from('parents')
            .select()
            .eq('name', parentName)
            .eq('phone', parentPhone)
            .maybeSingle();

        String parentId;

        if (parentResponse == null) {
          // Ask advisor to enter parent details manually
          final addManually = await _askManualParentEntry(studentName);
          if (addManually) {
            final manualParent = await _enterParentDetailsDialog(parentName, parentPhone, parentAddress);
            if (manualParent == null) {
              // Skip this student if canceled
              continue;
            }

            final insertedParent = await supabase.from('parents').insert({
              'name': manualParent['name'],
              'phone': manualParent['phone'],
              'address': manualParent['address'],
            }).select().single();

            parentId = insertedParent['id'];
          } else {
            // Skip this student
            continue;
          }
        } else {
          parentId = parentResponse['id'];
        }

        // Insert student
        try {
          await supabase.from('students').insert({
            'name': studentName,
            'phone': studentPhone,
            'parent_id': parentId,
            'parent_address': parentAddress,
            'class_advisor_id': widget.advisorId,
            'batch': widget.batch,
          });
          insertedCount++;
        } catch (e) {
          print('❌ Error inserting student $studentName: $e');
        }
      }

      setState(() {
        isUploading = false;
        message = '✅ Successfully inserted $insertedCount students!';
      });
    } catch (e) {
      print('❌ Error uploading CSV: $e');
      setState(() {
        isUploading = false;
        message = '❌ Error: $e';
      });
    }
  }

  Future<bool> _askManualParentEntry(String studentName) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Parent not found for $studentName'),
        content: const Text('Do you want to enter parent details manually?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Future<Map<String, String>?> _enterParentDetailsDialog(
      String name, String phone, String address) async {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    final addressController = TextEditingController(text: address);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter Parent Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Parent Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
                'address': addressController.text.trim(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Add Students')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload CSV File"),
                onPressed: isUploading ? null : _pickAndUploadCSV,
              ),
              const SizedBox(height: 20),
              if (isUploading) const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: message.contains('❌')
                      ? Colors.red
                      : message.contains('✅')
                          ? Colors.green
                          : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
