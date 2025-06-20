import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:workmate/model/user.dart';
import 'package:workmate/view/editsubmission.dart';
import 'package:workmate/myconfig.dart';

class HistoryScreen extends StatefulWidget {
  final User user;
  const HistoryScreen({super.key, required this.user});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List submissions = [];
  bool _isLoading = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fetchSubmissions();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> fetchSubmissions() async {
    setState(() => _isLoading = true);
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
        _animController.forward();
      } else {
        _showError("No submissions found");
      }
    } else {
      _showError("Server error");
    }
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("❌ $message"),
      backgroundColor: Colors.red.shade400,
    ));
  }

  void editSubmission(Map submission) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditSubmissionScreen(submission: submission),
      ),
    );

    if (updated == true) {
      fetchSubmissions();
    }
  }

  String _formatDate(String raw) {
    try {
      DateTime dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return raw.split(' ')?.first ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? Center(
                  child: GestureDetector(
                    onTap: fetchSubmissions,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inbox, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "No submissions yet.\nTap to refresh.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              : AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final s = submissions[index];
                        final animation = Tween<Offset>(
                          begin: Offset(0, 0.2 + index * 0.05),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animController,
                          curve: Interval(0, 1, curve: Curves.easeOut),
                        ));

                        return FadeTransition(
                          opacity: _animController,
                          child: SlideTransition(
                            position: animation,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.all(16),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFD0EBFF),
                                  child: Icon(Icons.description_outlined, color: Color.fromARGB(255, 0, 0, 0)),
                                ),
                                title: Text(
                                  s['title'] ?? 'No Title',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  _formatDate(s['submitted_at'] ?? ''),
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['submission_text'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: ElevatedButton.icon(
                                            onPressed: () => editSubmission(s),
                                            icon: const Icon(Icons.edit_note),
                                            label: const Text("Edit Submission"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF6D87E0),
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
