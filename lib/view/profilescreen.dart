import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:workmate/model/user.dart';
import 'package:workmate/myconfig.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final void Function(User) onProfileUpdated;
  const ProfileScreen({super.key, required this.user, required this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  File? _image;
  Uint8List? webImageBytes;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: showSelectionDialog,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? _buildProfileImage()
                        : widget.user.userImage.isNotEmpty
                            ? NetworkImage("${MyConfig.myurl}/workmate/assets/images/${widget.user.userImage}")
                            : const AssetImage("assets/images/profile.png") as ImageProvider,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: TextEditingController(text: widget.user.userId),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "User ID"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  readOnly: true,
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
                  onPressed: updateProfile,
                  child: const Text("Update Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                  child: const Text("From Camera")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _selectFromGallery();
                  },
                  child: const Text("From Gallery")),
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

  Future<void> _selectFromGallery() async {
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

  void updateProfile() async {
    String fullName = fullNameController.text;
    String phone = phoneController.text;
    String address = addressController.text;
    String imageBase64 = "";
    String imageName = widget.user.userImage;

    if (kIsWeb && webImageBytes != null) {
      imageBase64 = base64Encode(webImageBytes!);
      imageName = "";
    } else if (_image != null) {
      imageBase64 = base64Encode(_image!.readAsBytesSync());
      imageName = "";
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workmate/php/update_worker.php"),
        body: {
          "worker_id": widget.user.userId,
          "full_name": fullName,
          "phone": phone,
          "address": address,
          "image": imageBase64,
        },
      );

      if (response.statusCode == 200) {
        final jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          final updatedUser = User(
            userId: widget.user.userId,
            userName: fullName,
            userEmail: widget.user.userEmail,
            userPassword: widget.user.userPassword,
            userPhone: phone,
            userAddress: address,
            userImage: jsondata['image'] ?? imageName,
          );

          widget.onProfileUpdated(updatedUser);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsondata['message'] ?? "Update failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
