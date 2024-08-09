import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  Future<void> _signUp(
      BuildContext context, String email, String password) async {
    const url = 'http://localhost:3000/signup'; // Update to your backend URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        // Navigate to the main page or dashboard
        Navigator.pushReplacementNamed(
            context, '/stocks'); // Adjust route as needed
      } else if (response.statusCode == 400) {
        // If user already exists, navigate to sign-in page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User already exists. Please sign in.')),
        );
        Navigator.pushReplacementNamed(
            context, '/sign-in'); // Adjust route as needed
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-up failed: ${response.body}')),
        );
      }
    } catch (error) {
      // Handle network error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blueGrey.shade800,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'Enter your email',
                hintStyle: const TextStyle(color: Colors.white60),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'Enter your password',
                hintStyle: const TextStyle(color: Colors.white60),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _signUp(context, emailController.text, passwordController.text);
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
