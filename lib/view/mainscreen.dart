import 'package:flutter/material.dart';
import 'package:workmate/model/user.dart';
import 'package:workmate/view/loginscreen.dart';
import 'package:workmate/view/registerscreen.dart';
import 'package:workmate/view/profilescreen.dart';
import 'package:workmate/view/tasklistscreen.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 155, 235, 255),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(user: widget.user), // null for logout
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          tooltip: 'My Profile',
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(user: widget.user),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome, ${widget.user.userName}!",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt, color: Colors.black),
                label: const Text("View My Tasks", style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskListScreen(user: widget.user),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: const Color.fromARGB(255, 162, 236, 255),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Register or Add',
        onPressed: () {
          if (widget.user.userId == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RegisterScreen(user: widget.user),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Feature to add new content will be available soon."),
                backgroundColor: Colors.grey,
              ),
            );
          }
        },
        backgroundColor: const Color.fromARGB(255, 184, 185, 187),
        child: const Icon(Icons.add),
      ),
    );
  }
}
