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
  bool _isUpdating = false;

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
                  decoration: const InputDecoration(labelText: "User ID", prefixIcon: Icon(Icons.perm_identity)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone", prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address", prefixIcon: Icon(Icons.location_on)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CF7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Update Profile"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("From Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _selectFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("From Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _selectFromGallery();
                },
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
    String fullName = fullNameController.text.trim();
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();

    if (fullName.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all the fields"),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Are you sure you want to update your profile?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A6CF7),
              foregroundColor: Colors.white,
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (shouldUpdate != true) return;

    setState(() => _isUpdating = true);

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
            const SnackBar(
              content: Text("Profile updated successfully"),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsondata['message'] ?? "Update failed"),
              backgroundColor: Color(0xFFF44336),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server error"),
            backgroundColor: Color(0xFFF44336),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }
}
