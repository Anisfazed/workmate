import 'package:flutter/material.dart';
import 'package:workmate/model/user.dart';
import 'package:workmate/myconfig.dart';
import 'package:workmate/view/updateprofile.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final Function(User) onProfileUpdated;

  const ProfileScreen({super.key, required this.user, required this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _getProfileImage(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileInfo(),
                    const SizedBox(height: 20),
                    _buildEditButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getProfileImage() {
    if (_currentUser.userImage.isNotEmpty) {
      return NetworkImage(
        "${MyConfig.myurl}/workmate/assets/images/${_currentUser.userImage}?v=${DateTime.now().millisecondsSinceEpoch}",
      );
    }
    return const AssetImage("assets/images/profile.png");
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        _infoTile("User ID", _currentUser.userId, Icons.perm_identity),
        const SizedBox(height: 10),
        _infoTile("Full Name", _currentUser.userName, Icons.person),
        const SizedBox(height: 10),
        _infoTile("Email", _currentUser.userEmail, Icons.email),
        const SizedBox(height: 10),
        _infoTile("Phone", _currentUser.userPhone, Icons.phone),
        const SizedBox(height: 10),
        _infoTile("Address", _currentUser.userAddress, Icons.location_on),
      ],
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value.isNotEmpty ? value : "Not set"),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.edit),
        label: const Text("Edit Profile"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A6CF7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _navigateToUpdateProfile(),
      ),
    );
  }

  Future<void> _navigateToUpdateProfile() async {
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProfileScreen(
          user: _currentUser,
          onProfileUpdated: (newUser) {
            setState(() => _currentUser = newUser);
            widget.onProfileUpdated(newUser);
          },
        ),
      ),
    );

    if (updatedUser != null) {
      setState(() => _currentUser = updatedUser);
    }
  }
}