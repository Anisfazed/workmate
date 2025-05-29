import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:workmate/model/task.dart';
import 'package:workmate/model/user.dart';
import 'package:workmate/view/submitscreen.dart';
import 'package:workmate/myconfig.dart';

class TaskListScreen extends StatefulWidget {
  final User user;

  const TaskListScreen({Key? key, required this.user}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<dynamic> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final userId = widget.user.userId;

    if (userId == null || userId == '0') {
      _showSnackBar("Invalid user ID. Cannot load tasks.", Colors.red);
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workmate/php/get_works.php"),
        body: {'worker_id': userId},
      );

      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && decoded['status'] == 'success') {
        setState(() {
          tasks = List<Task>.from(decoded['data'].map((t) => Task.fromJson(t)));
          isLoading = false;
        });
      } else {
        _showSnackBar(decoded['message'] ?? "Failed to load tasks", Colors.orange);
        setState(() {
          tasks = [];
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 155, 235, 255),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks found.", style: TextStyle(fontSize: 16)))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isCompleted = task.status == 'success' || task.status == 'completed';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: isCompleted ? Colors.green[100] : Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(
                          isCompleted ? Icons.check_circle : Icons.pending_actions,
                          color: isCompleted ? Colors.green : Colors.orange,
                          size: 28,
                        ),
                        title: Text(
                          task.title ?? 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description ?? 'No Description'),
                              const SizedBox(height: 4),
                              Text("Due: ${task.dueDate ?? 'N/A'}"),
                              Text("Status: ${task.status ?? 'unknown'}"),
                            ],
                          ),
                        ),
                        trailing: isCompleted ? null : const Icon(Icons.arrow_forward_ios),
                        onTap: isCompleted
                            ? null
                            : () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubmitScreen(
                                      user: widget.user,
                                      task: task,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadTasks(); // Refresh after submission
                                }
                              },
                      ),
                    );
                  },
                ),
    );
  }
}
