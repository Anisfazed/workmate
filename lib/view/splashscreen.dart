import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:workmate/model/user.dart';
import 'package:workmate/myconfig.dart';
import 'package:workmate/view/mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      loadUserCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:[
              const Color.fromARGB(255, 185, 212, 245), 
              const Color.fromARGB(255, 235, 235, 235)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", scale: 3.5),
              const CircularProgressIndicator(
                backgroundColor: Color.fromARGB(255, 0, 0, 0),
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 255, 255, 255)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('pass') ?? '';
    bool rem = prefs.getBool('remember') ?? false;

    if (rem == true) {
      http.post(Uri.parse("${MyConfig.myurl}/workmate/php/login_worker.php"), body: {
        "email": email,
        "password": password,
      }).then((response) {
        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          if (jsondata['status'] == 'success') {
            var userdata = jsondata['data'];
            User user = User.fromJson(userdata[0]);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
          } else {
            _navigateAsGuest();
          }
        }
      });
    } else {
      _navigateAsGuest();
    }
  }

  void _navigateAsGuest() {
    User user = User(
      userId: "0",
      userName: "Guest",
      userEmail: "",
      userPhone: "",
      userAddress: "",
      userPassword: "",
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(user: user)),
    );
  }
}