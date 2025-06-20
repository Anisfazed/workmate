import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:workmate/model/user.dart';
import 'package:workmate/myconfig.dart';

class UpdateProfileScreen extends StatefulWidget {
  final User user;
  final Function(User) onProfileUpdated;

  const UpdateProfileScreen({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  File? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.userName);
    _phoneController = TextEditingController(text: widget.user.userPhone);
    _addressController = TextEditingController(text: widget.user.userAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  setState(() {
                    _imageFile = null;
                    _webImage = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          _webImage = await pickedFile.readAsBytes();
        } else {
          _imageFile = File(pickedFile.path);
        }
        setState(() {});
      }
    } catch (e) {
      _showSnackBar("Failed to pick image: ${e.toString()}");
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar("Name cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageBase64;
      if (_imageFile != null) {
        imageBase64 = base64Encode(await _imageFile!.readAsBytes());
      } else if (_webImage != null) {
        imageBase64 = base64Encode(_webImage!);
      }

      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workmate/php/update_worker.php"),
        body: {
          "worker_id": widget.user.userId,
          "full_name": _nameController.text,
          "phone": _phoneController.text,
          "address": _addressController.text,
          "image": imageBase64 ?? "",
        },
      );

      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        final updatedUser = User(
          userId: widget.user.userId,
          userName: _nameController.text,
          userEmail: widget.user.userEmail,
          userPassword: widget.user.userPassword,
          userPhone: _phoneController.text,
          userAddress: _addressController.text,
          userImage: responseData['image'] ?? widget.user.userImage,
        );

        widget.onProfileUpdated(updatedUser);
        Navigator.pop(context, updatedUser);
        _showSnackBar("Profile updated successfully", isError: false);
      } else {
        _showSnackBar(responseData['message'] ?? "Update failed");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
        backgroundColor: const Color.fromARGB(255, 156, 182, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _getImageProvider(),
                    child: _imageFile == null && _webImage == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                        : null,
                  ),
                  if (_imageFile != null || _webImage != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, size: 20, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nameController, "Full Name", Icons.person),
            const SizedBox(height: 15),
            _buildTextField(_phoneController, "Phone", Icons.phone),
            const SizedBox(height: 15),
            _buildTextField(_addressController, "Address", Icons.location_on),
            const SizedBox(height: 25),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider() {
    if (_imageFile != null) return FileImage(_imageFile!);
    if (_webImage != null) return MemoryImage(_webImage!);
    if (widget.user.userImage.isNotEmpty) {
      return NetworkImage(
        "${MyConfig.myurl}/workmate/assets/images/${widget.user.userImage}",
      );
    }
    return null;
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A6CF7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Update", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}