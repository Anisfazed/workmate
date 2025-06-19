// edit_submission.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:workmate/myconfig.dart';

class EditSubmissionScreen extends StatefulWidget {
  final Map submission;

  const EditSubmissionScreen({super.key, required this.submission});

  @override
  State<EditSubmissionScreen> createState() => _EditSubmissionScreenState();
}

class _EditSubmissionScreenState extends State<EditSubmissionScreen> {
  late TextEditingController _submissionController;

  @override
  void initState() {
    super.initState();
    _submissionController = TextEditingController(text: widget.submission['submission_text']);
  }

  Future<void> _updateSubmission() async {
    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workmate/php/edit_submission.php"),
      body: {
        'submission_id': widget.submission['id'],
        'updated_text': _submissionController.text,
      },
    );

    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      Navigator.pop(context, true); // signal success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: ${data['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Submission"),
        backgroundColor: const Color.fromARGB(255, 155, 235, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Task Title: ${widget.submission['title'] ?? 'Untitled'}"),
            const SizedBox(height: 10),
            TextField(
              controller: _submissionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Edit your submission',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _updateSubmission,
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
