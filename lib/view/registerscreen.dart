import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:workmate/model/user.dart';
import 'package:workmate/myconfig.dart';
import 'package:workmate/view/loginscreen.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  final User user;
  const RegisterScreen({super.key, required this.user});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? _image;
  Uint8List? webImageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Screen"),
        backgroundColor: const Color.fromARGB(0, 177, 207, 219),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 185, 212, 245),
              Color.fromARGB(255, 245, 254, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.95),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: showSelectionDialog,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: _image == null
                                  ? const AssetImage("assets/images/camera.png")
                                  : _buildProfileImage(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: "Your Name",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: "Confirm Password",
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Phone",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: registerUserDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 193, 243, 255),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Register", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void registerUserDialog() {
    String full_name = fullNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();

    if (_image == null && (webImageBytes == null || kIsWeb)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    if (full_name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

   

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Register this account?"),
          content: const Text("Are you sure?"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                registerUser();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> registerUser() async {
    String full_name = fullNameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String phone = phoneController.text;
    String address = addressController.text;
    String base64Image = kIsWeb
        ? base64Encode(webImageBytes!)
        : base64Encode(_image!.readAsBytesSync());

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workmate/php/register_worker.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "full_name": full_name,
          "email": email,
          "password": password,
          "phone": phone,
          "address": address,
          "image": base64Image,
        },
      );

      var jsondata = json.decode(response.body);
      if (response.statusCode == 200) {
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Success!"),
            backgroundColor: Colors.green,
          ),
        );

          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(user: widget.user),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsondata['message'] ?? "Failed to register")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select from"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _selectFromCamera();
                },
                child: const Text("From Camera"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _selectfromGallery();
                },
                child: const Text("From Gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) webImageBytes = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  Future<void> _selectfromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) webImageBytes = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  ImageProvider _buildProfileImage() {
    if (kIsWeb && webImageBytes != null) {
      return MemoryImage(webImageBytes!);
    } else if (_image != null) {
      return FileImage(_image!);
    }
    return const AssetImage('assets/images/profile.png');
  }
}
