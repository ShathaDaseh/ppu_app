import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoadingInitial = false;

  @override
  void initState() {
    super.initState();
    _isLoadingInitial = true;
    getPage();
  }

  getPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('sessionToken');
    if (sessionToken != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
    setState(() {
      _isLoadingInitial = false;
    });
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoadingLogin = false;
  String _errorMessage = '';

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      _isLoadingLogin = true;
      _errorMessage = '';
    });

    final url = 'http://feeds.ppu.edu/api/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final sessionToken = responseData['session_token'];
        final username = responseData['username'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('sessionToken', sessionToken);
        await prefs.setString('username', username);

        Navigator.pushReplacementNamed(context, '/home', arguments: {
          'username': username,
          'sessionToken': sessionToken,
        });
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password.';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to login. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoadingLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A1C2F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingInitial
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please log in to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoadingLogin ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF4A1C2F),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoadingLogin
                          ? CircularProgressIndicator(color: Color(0xFF4A1C2F))
                          : Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
