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
  int _selectedDrawerIndex = -1; // -1 = Home

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      TaskListScreen(user: widget.user),
      HistoryScreen(user: widget.user),
      ProfileScreen(user: widget.user, onProfileUpdated: (User ) {  },),
    ]);
  }

  void _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close drawer
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
              backgroundImage: widget.user.userImage.isNotEmpty
                  ? NetworkImage("${MyConfig.myurl}/workmate/assets/images/${widget.user.userImage}")
                  : const AssetImage("assets/images/profile.png") as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome, ${widget.user.userName}!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Use the drawer menu to manage tasks, view history, or update your profile.",
              textAlign: TextAlign.center,
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
              accountName: Text(widget.user.userName),
              accountEmail: Text(widget.user.userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: widget.user.userImage.isNotEmpty
                    ? NetworkImage("${MyConfig.myurl}/workmate/assets/images/${widget.user.userImage}")
                    : const AssetImage("assets/images/profile.png") as ImageProvider,
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 156, 182, 255),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              selected: _selectedDrawerIndex == 0,
              onTap: () => _onSelectItem(0),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              selected: _selectedDrawerIndex == 1,
              onTap: () => _onSelectItem(1),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: _selectedDrawerIndex == 2,
              onTap: () => _onSelectItem(2),
            ),
          ],
        ),
      ),
      body: _selectedDrawerIndex == -1 ? _buildHome() : _screens[_selectedDrawerIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            setState(() => _selectedDrawerIndex = -1); // switch to Home
          } else if (index == 1) {
            _logout(); // logout when second item tapped
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Logout",
          ),
        ],
      ),
    );
  }
}
