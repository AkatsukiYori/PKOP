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

  bool _isLoading = false;
  String _message = '';

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = Uri.parse('http://localhost/backend_project_rpl/auth/register.php');

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
        setState(() {
          _isLoading = false;
          _message = data["message"];
        });

        if (data["status"] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("✅ Sign up Berhasil")));
          // Navigate to the next page after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginWidget(),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _usernameController,
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
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.key, color: Colors.grey[600]),
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 10),
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
