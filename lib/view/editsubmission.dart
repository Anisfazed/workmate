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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _submissionController = TextEditingController(
      text: widget.submission['submission_text'] ?? '',
    );
  }

  Future<void> _confirmAndUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Are you sure you want to update this submission?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom( 
              backgroundColor: const Color(0xFF4A6CF7),
              foregroundColor: Colors.white,),
            child: const Text("Yes, Update"),
          ),
        ],
      ),
    );

    if (shouldUpdate == true) {
      _updateSubmission();
    }
  }

  Future<void> _updateSubmission() async {
    setState(() => _isSaving = true);

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workmate/php/edit_submission.php"),
        body: {
          'submission_id': widget.submission['id'],
          'updated_text': _submissionController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        Navigator.pop(context, true); // Notify previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Submission updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed: ${data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskTitle = widget.submission['title'] ?? 'Untitled Task';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Submission"),
        backgroundColor: const Color.fromARGB(255, 156, 182, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Editing Submission for:",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    taskTitle,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _submissionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Your Submission',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Submission text cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_isSaving || _submissionController.text.trim() == widget.submission['submission_text'])
                          ? null
                          : _confirmAndUpdate,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? "Saving..." : "Save Changes"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color.fromARGB(255, 156, 182, 255),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
