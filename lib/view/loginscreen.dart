import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workmate/model/user.dart';
import 'package:workmate/myconfig.dart';
import 'package:workmate/view/mainscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmate/view/registerscreen.dart';

class LoginScreen extends StatefulWidget {
  final User user;

  const LoginScreen({super.key, required this.user});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isChecked = false;
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
        backgroundColor: const Color.fromARGB(255, 155, 235, 255),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/wtms.png",
                    height: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: "Email",
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                labelText: "Password",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscureText,
                            ),
                            Row(
                              children: [
                                const Text("Remember Me"),
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isChecked = value!;
                                    });

                                    String email = emailController.text;
                                    String password = passwordController.text;

                                    if (isChecked) {
                                      if (email.isEmpty || password.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content:
                                              Text("Please fill all fields"),
                                          backgroundColor: Colors.red,
                                        ));
                                        setState(() {
                                          this.isChecked = false;
                                        });
                                        return;
                                      }
                                    }
                                    storeCredentials(
                                        email, password, isChecked);
                                  },
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                loginUser();
                              },
                              child: const Text("Login"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(user: widget.user),
                        ),
                      );
                    },
                    child: const Text("Register an account?"),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: const Text("Forgot Password?"),
                  ),
                ],
              ),
            ),
    );
  }

  void loginUser() {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all fields"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    http.post(Uri.parse("${MyConfig.myurl}/workmate/php/login_worker.php"), body: {
      "email": email,
      "password": password,
    }).then((response) {
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'success') {
          var userdata = jsondata['data'];
          User user = User.fromJson(userdata[0]);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Welcome ${user.userName}"),
            backgroundColor: Colors.green,
          ));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(user: user),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login failed! Please check your credentials."),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Server error. Please try again later."),
          backgroundColor: Colors.red,
        ));
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $error"),
        backgroundColor: Colors.red,
      ));
    });
  }

  Future<void> storeCredentials(
      String email, String password, bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      await prefs.setBool('remember', isChecked);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences saved!"),
        backgroundColor: Colors.green,
      ));
    } else {
      await prefs.remove('email');
      await prefs.remove('pass');
      await prefs.remove('remember');
      emailController.clear();
      passwordController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences cleared."),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> loadCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  String? password = prefs.getString('pass');
  bool? remember = prefs.getBool('remember');

  if (remember != null && remember) {
    setState(() {
      emailController.text = email ?? "";
      passwordController.text = password ?? "";
      isChecked = true;
    });
  }
}

}
