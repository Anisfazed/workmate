import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workmate/model/user.dart';
import 'package:workmate/view/loginscreen.dart';
import 'package:workmate/myconfig.dart';
import 'package:workmate/view/mainscreen.dart';

class ProfileScreen extends StatefulWidget {
  final User user; // The user data passig the data from login page to main screen page

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers to manage text field input of user
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

 @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.user.userName);
    emailController = TextEditingController(text: widget.user.userEmail);
    phoneController = TextEditingController(text: widget.user.userPhone);
    addressController = TextEditingController(text: widget.user.userAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Screen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logs out the user and navigates to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen(user: widget.user)),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF4F6F7), // Light background color
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/profile.png"), // Profile image placeholder
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  readOnly: true, // Email is not editable
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: updateProfile, // Calls function to update profile
                  child: const Text("Update Profile"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Sends updated profile information to the backend
  void updateProfile() async {
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/update_worker.php"),
        body: {
          "id": widget.user.userId,
          "full_name": fullNameController.text,
          "phone": phoneController.text,
          "address": addressController.text,
        },
      );

      if (response.statusCode == 200 && response.body.contains('status')) {
        final jsondata = jsonDecode(response.body);

        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                user: User(
                  userId: widget.user.userId,
                  userName: fullNameController.text,
                  userEmail: widget.user.userEmail,
                  userPassword: widget.user.userPassword,
                  userPhone: phoneController.text,
                  userAddress: addressController.text,
                ),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsondata['message'] ?? "Update failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid response from server")),
        );
      }
    } catch (error) {
      print("HTTP error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection failed")),
      );
    }
  }
}