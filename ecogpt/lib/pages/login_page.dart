import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_services.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      final response = await ApiServices.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (response['status'] == 'success') {
        var userData = response['user_data'];

        Map<String, dynamic> parsedUserData = {};

        if (userData is List && userData.length >= 5) {
          parsedUserData = {
            "user_id": userData[0],
            "username": userData[1],
            "name": userData[2],
            "cc_point": userData[3],
            "demerits": userData[4],
          };
        } else if (userData is Map<String, dynamic>) {
          parsedUserData = userData;
        } else {
          setState(() {
            _errorMessage = "Invalid user data format";
          });
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(userData: parsedUserData),
          ),
        );
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(
                    255,
                    190,
                    11,
                    89,
                  ).withOpacity(_animation.value),
                  Color.fromARGB(
                    255,
                    55,
                    94,
                    201,
                  ).withOpacity(_animation.value),
                  Color.fromARGB(
                    255,
                    145,
                    157,
                    15,
                  ).withOpacity(_animation.value),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getGreetingMessage(),
                  style: GoogleFonts.pacifico(
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(_usernameController, "Username", Icons.person),
                SizedBox(height: 10),
                _buildTextField(
                  _passwordController,
                  "Password",
                  Icons.lock,
                  true,
                ),
                SizedBox(height: 10),
                _buildLoginButton(),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    // Handle forgot password
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning!";
    } else if (hour < 17) {
      return "Good Afternoon!";
    } else {
      return "Good Evening!";
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    bool obscureText = false,
  ]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          labelStyle: TextStyle(color: Colors.black),
          contentPadding: EdgeInsets.all(16),
        ),
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amberAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(vertical: 15),
        textStyle: TextStyle(fontSize: 18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value + 1,
                child: Icon(Icons.login, color: Colors.white),
              );
            },
          ),
          SizedBox(width: 10),
          Text("Login"),
        ],
      ),
    );
  }
}
