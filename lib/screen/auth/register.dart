import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_rpl/screen/auth/login.dart';
import 'package:http/http.dart' as http;

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    final url = Uri.parse(
      'http://10.0.2.2/backend_project_rpl/auth/register.php',
    );

    final response = await http.post(
      url,
      body: jsonEncode({
        "email": _emailController.text,
        "username": _usernameController.text,
        "password": _passwordController.text,
      }),
    );

    if (!mounted) return;

    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        if (data["status"] == true) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    'Berhasil',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    textAlign: TextAlign.center,
                    'Sign up berhasil',
                    style: TextStyle(fontSize: 14),
                  ),
                  backgroundColor: Color(0xFFF9FCFF),
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 55,
                  ),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4C75FF),
                          foregroundColor: Colors.white,
                          fixedSize: Size(
                            MediaQuery.of(context).size.width * 0.3,
                            40,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ),
                  ],
                ),
          );
          // Navigate to the next page after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginWidget(),
            ), // Replace HomePage() with your target page
          );
        } else {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    'Gagal',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    textAlign: TextAlign.center,
                    data['message'],
                    style: TextStyle(fontSize: 14),
                  ),
                  backgroundColor: Color(0xFFF9FCFF),
                  icon: Icon(Icons.error_outline, color: Colors.red, size: 55),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4C75FF),
                          foregroundColor: Colors.white,
                          fixedSize: Size(
                            MediaQuery.of(context).size.width * 0.3,
                            40,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ),
                  ],
                ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  'Gagal',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                content: Text(
                  textAlign: TextAlign.center,
                  'Error: ${e.toString()}',
                  style: TextStyle(fontSize: 14),
                ),
                backgroundColor: Color(0xFFF9FCFF),
                icon: Icon(Icons.error_outline, color: Colors.red, size: 55),
                actions: [
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4C75FF),
                        foregroundColor: Colors.white,
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.3,
                          40,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ),
                ],
              ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Gagal',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              content: Text(
                textAlign: TextAlign.center,
                'Empty response from server.',
                style: TextStyle(fontSize: 14),
              ),
              backgroundColor: Color(0xFFF9FCFF),
              icon: Icon(Icons.error_outline, color: Colors.red, size: 55),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4C75FF),
                      foregroundColor: Colors.white,
                      fixedSize: Size(
                        MediaQuery.of(context).size.width * 0.3,
                        40,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ),
              ],
            ),
      );
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
                'Sign Up',
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
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF4C75FF)),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF4C75FF)),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.key, color: Colors.grey[600]),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF4C75FF)),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF4C75FF),
                  foregroundColor: Colors.white,
                  fixedSize: Size(MediaQuery.of(context).size.width * 1, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _register,
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah memiliki akun?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginWidget()),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                      foregroundColor: Color(0xFF4C75FF),
                    ),
                    child: Text('Login Disini'),
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
