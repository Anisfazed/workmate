import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:workmate/model/user.dart';
import 'package:workmate/model/task.dart';
import 'package:workmate/myconfig.dart';

class SubmitScreen extends StatefulWidget {
  final User user;
  final Task task;

  const SubmitScreen({
    Key? key,
    required this.user,
    required this.task,
  }) : super(key: key);

  @override
  _SubmitScreenState createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final TextEditingController _submissionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitTask() async {
    final workId = widget.task.workId;
    final workerId = widget.user.userId ?? '0';
    final submissionText = _submissionController.text.trim();

    if (submissionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe what you completed.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workmate/php/submit_work.php"),
        body: {
          'work_id': workId,
          'worker_id': workerId,
          'submission_text': submissionText,
        },
      );

      final decoded = json.decode(response.body);
      setState(() => _isSubmitting = false);

      if (decoded['status'] == 'success') {
        Navigator.pop(context, true); // Refresh parent screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(decoded['message'] ?? 'Submission successful'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(decoded['message'] ?? 'Submission failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Task', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
        backgroundColor:const Color.fromARGB(255, 155, 235, 255),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.task.title ?? 'No Title',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              'Your Submission',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _submissionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Describe what you completed for this task...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color.fromARGB(255, 175, 208, 255),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isSubmitting ? null : _submitTask,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
