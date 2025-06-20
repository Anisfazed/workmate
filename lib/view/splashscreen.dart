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
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack);
    _logoController.forward();

    Future.delayed(const Duration(seconds: 5), () {
      User guestUser = User(
        userId: "0",
        userName: "Guest",
        userEmail: "",
        userPhone: "",
        userAddress: "",
        userImage: "",
        userPassword: "",
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen(user: guestUser)),
      );
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
        width: double.infinity,
        height: double.infinity,
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _logoAnimation,
                child: FadeTransition(
                  opacity: _logoAnimation,
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 300,
                    height: 280,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Lottie.asset(
                'assets/lottie/loading.json',
                width: 200,
                height: 300,
              ),
              const SizedBox(height: 10),
              const Text(
                "Getting things ready...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(134, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
