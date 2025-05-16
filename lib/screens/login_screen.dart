// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.9],
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
                  offset: Offset(0, 10),
                ),
              ],
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 0.9],
                colors: [
                  Colors.white,
                  Colors.orange[50]!,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Image.asset(
                    'images/pokeball_image.png',
                    width: 180,
                    height: 180,
                  ),
                  Text(
                    "Welcome back,  Trainer!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  CustomTextField(
                      emailController: _emailController,
                      text: "Email",
                      icon: Icons.email),
                  CustomTextField(
                    emailController: _passwordController,
                    text: "Password",
                    icon: Icons.remove_red_eye,
                    isPassword: true,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle login logic here
                      print("the login button was pressed");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 130),
                    ),
                    child: Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("--------- OR ---------",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? | ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.orange[500],
                          decoration: TextDecoration.none,
                        ),
                      )
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

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.emailController,
    required this.text,
    required this.icon,
    this.isPassword = false,
    this.paddingLeftRight = 32,
    this.thickness = 2,
  });

  final double paddingLeftRight;
  final TextEditingController emailController;
  final String text;
  final IconData icon;
  final bool isPassword;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          right: paddingLeftRight, left: paddingLeftRight, top: 20),
      child: TextField(
        obscureText: isPassword,
        controller: emailController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          prefixIcon: Icon(
            icon,
            color: Colors.black,
          ),
          labelText: text,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide:
                BorderSide(color: Colors.orange[400]!, width: thickness),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.amber[400]!, width: thickness),
          ),
        ),
      ),
    );
  }
}
