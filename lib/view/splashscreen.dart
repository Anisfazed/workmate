import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:workmate/model/user.dart';
import 'package:workmate/view/loginscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _logoAnimation = CurvedAnimation(parent: _logoController, curve: Curves.easeInOut);
    _logoController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      User guestUser = User(userId: "0", userName: "Guest", userEmail: "", userPhone: "", userAddress: "", userImage: "", userPassword: '');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(user: guestUser)));
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 185, 212, 245), Color.fromARGB(255, 235, 235, 235)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoAnimation,
                child: FadeTransition(
                  opacity: _logoAnimation,
                  child: Image.asset("assets/images/logo.png", scale: 3.5),
                ),
              ),
              const SizedBox(height: 40),
              Lottie.asset('assets/lottie/loading.json', width: 100, height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
