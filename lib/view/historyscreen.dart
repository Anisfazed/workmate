import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workmate/model/user.dart';
import 'package:workmate/view/editsubmission.dart';
import 'package:workmate/myconfig.dart';

class HistoryScreen extends StatefulWidget {
  final User user;
  const HistoryScreen({super.key, required this.user});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workmate/php/get_submissions.php"),
      body: {'worker_id': widget.user.userId},
    );

    if (response.statusCode == 200) {
      final jsondata = jsonDecode(response.body);
      if (jsondata['status'] == 'success') {
        setState(() {
          submissions = jsondata['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load submissions")),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error")),
      );
    }
  }

  void editSubmission(Map submission) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditSubmissionScreen(submission: submission),
      ),
    );

    if (updated == true) {
      fetchSubmissions(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : submissions.isEmpty
            ? const Center(child: Text("No submissions found."))
            : ListView.builder(
                itemCount: submissions.length,
                itemBuilder: (context, index) {
                  final s = submissions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(s['title'] ?? 'No Title'),
                      subtitle: Text(
                        (s['submission_text'] as String).length > 50
                            ? "${s['submission_text'].substring(0, 50)}..."
                            : s['submission_text'],
                      ),
                      trailing: Text(s['submitted_at'] ?? ''),
                      onTap: () => editSubmission(s),
                    ),
                  );
                },
              );
  }
}
