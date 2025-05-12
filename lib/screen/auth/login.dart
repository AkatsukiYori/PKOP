import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_rpl/screen/main/home.dart';
import 'package:project_rpl/screen/auth/register.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _message = '';

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username atau password tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = Uri.parse(
      'http://localhost/backend_project_rpl/auth/login.php',
    );

    final response = await http.post(
      url,
      body: jsonEncode({
        "username": _usernameController.text,
        "password": _passwordController.text,
      }),
    );

    if (!mounted) return;

    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _message = data["message"];
        });

        if (data["status"] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id', data['data']);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("✅ Login Successful")));
          // Navigate to the next page after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeWidget(),
            ), // Replace HomePage() with your target page
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ ${data['message']}")));
        }
      } catch (e) {
        // If JSON parsing fails, show error
        setState(() {
          _isLoading = false;
          _message = "Error parsing response: ${e.toString()}";
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Error: ${e.toString()}")));
      }
    } else {
      setState(() {
        _isLoading = false;
        _message = "Empty response from server.";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Empty response from server.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                'Silahkan masukan data anda',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                autocorrect: false,
                autofillHints: Iterable.empty(),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                autocorrect: false,
                autofillHints: Iterable.empty(),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.key, color: Colors.grey[600]),
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              _isLoading
                  ? CircularProgressIndicator()
                  : TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF4C75FF),
                      foregroundColor: Colors.white,
                      fixedSize: Size(
                        MediaQuery.of(context).size.width * 1,
                        40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _login,
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Apakah anda belum memiliki akun?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterWidget(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                      foregroundColor: Color(0xFF4C75FF),
                    ),
                    child: Text('Daftar disini'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
