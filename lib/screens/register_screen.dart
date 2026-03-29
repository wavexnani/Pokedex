// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_x/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateInputs() {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      return 'Please fill in all required fields.';
    }
    if (name.length < 2) {
      return 'Name should have at least 2 characters.';
    }
    if (username.length < 3) {
      return 'Username should have at least 3 characters.';
    }
    if (password.length < 6) {
      return 'Password should be at least 6 characters long.';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _register() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      _showMessage(validationError, isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final url = Uri.parse('http://10.186.144.146:8080/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'name': _nameController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        _showMessage(data['message']?.toString() ?? 'Registration successful.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        _showMessage(
          data['message']?.toString() ?? 'Registration failed.',
          isError: true,
        );
      }
    } catch (_) {
      _showMessage(
        'Could not connect to server. Check backend and try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.1, 0.9],
            colors: [
              Colors.orange[50]!,
              Colors.orange[200]!,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 380,
            height: 750,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.1, 0.9],
                colors: [
                  Colors.white,
                  Colors.orange[50]!,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    'images/pokeball_image.png',
                    width: 170,
                    height: 170,
                  ),
                  const Text(
                    'Create Trainer Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      'Use your real name, pick a unique username, and set a strong password to secure your captures.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Required: Name (2+), Username (3+), Password (6+)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
                  _RegisterInputField(
                    controller: _nameController,
                    text: 'Full Name',
                    icon: Icons.badge,
                  ),
                  _RegisterInputField(
                    controller: _usernameController,
                    text: 'Username',
                    icon: Icons.person,
                  ),
                  _RegisterInputField(
                    controller: _passwordController,
                    text: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  _RegisterInputField(
                    controller: _confirmPasswordController,
                    text: 'Confirm Password',
                    icon: Icons.verified_user,
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 105,
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '--------- OR ---------',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? | ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.orange[500],
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterInputField extends StatelessWidget {
  const _RegisterInputField({
    required this.controller,
    required this.text,
    required this.icon,
    this.isPassword = false,
  });

  final TextEditingController controller;
  final String text;
  final IconData icon;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 32, left: 32, top: 20),
      child: TextField(
        obscureText: isPassword,
        controller: controller,
        decoration: InputDecoration(
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.black),
          labelText: text,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.amber[400]!, width: 2),
          ),
        ),
      ),
    );
  }
}
