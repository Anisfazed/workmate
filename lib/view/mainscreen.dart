import 'package:flutter/material.dart';
import 'package:workmate/model/user.dart';
import 'package:workmate/view/loginscreen.dart';
import 'package:workmate/view/tasklistscreen.dart';
import 'package:workmate/view/historyscreen.dart';
import 'package:workmate/view/profilescreen.dart';
import 'package:workmate/myconfig.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late User currentUser;
  int _selectedDrawerIndex = -1;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  void _updateUser(User updatedUser) {
    setState(() {
      currentUser = updatedUser;
    });
  }

  Widget _buildHome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: currentUser.userImage.isNotEmpty
                  ? NetworkImage("${MyConfig.myurl}/workmate/assets/images/${currentUser.userImage}?v=${DateTime.now().millisecondsSinceEpoch}")
                  : const AssetImage("assets/images/profile.png") as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome, ${currentUser.userName}!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Use the drawer menu to manage tasks, view history, or update your profile.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          user: User(
            userId: '',
            userName: '',
            userEmail: '',
            userPassword: '',
            userPhone: '',
            userAddress: '',
            userImage: '',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TaskListScreen(user: currentUser),
      HistoryScreen(user: currentUser),
      ProfileScreen(user: currentUser, onProfileUpdated: _updateUser),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedDrawerIndex == 0
              ? "My Tasks"
              : _selectedDrawerIndex == 1
                  ? "Submission History"
                  : _selectedDrawerIndex == 2
                      ? "My Profile"
                      : "Home",
        ),
        backgroundColor: const Color.fromARGB(255, 156, 182, 255),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                currentUser.userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                currentUser.userEmail,
                style: const TextStyle(color: Colors.black),
              ),
              currentAccountPicture: CircleAvatar(
                radius: 30,
                backgroundImage: currentUser.userImage.isNotEmpty
                    ? NetworkImage("${MyConfig.myurl}/workmate/assets/images/${currentUser.userImage}?v=${DateTime.now().millisecondsSinceEpoch}")
                    : const AssetImage("assets/images/profile.png") as ImageProvider,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 247, 215, 73),
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 173, 211, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              selected: _selectedDrawerIndex == 0,
              onTap: () {
                setState(() => _selectedDrawerIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              selected: _selectedDrawerIndex == 1,
              onTap: () {
                setState(() => _selectedDrawerIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: _selectedDrawerIndex == 2,
              onTap: () {
                setState(() => _selectedDrawerIndex = 2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _selectedDrawerIndex == -1 ? _buildHome() : screens[_selectedDrawerIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            setState(() => _selectedDrawerIndex = -1); // Home
          } else if (index == 1) {
            _logout(); // Logout
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
      ),
    );
  }
}