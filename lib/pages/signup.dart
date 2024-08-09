import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Define the function to store the token and user ID
Future<void> storeTokenAndUserId(String token, int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setInt('userId', userId);
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp(
      BuildContext context, String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    const url =
        'http://localhost:3000/signup'; // Replace with your computer's IP

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        final userId = responseBody['userId'];

        if (token != null && userId != null) {
          await storeTokenAndUserId(token, userId);
          print('Sign-up successful: $responseBody');

          // Initialize stocks for the user
          const initStockUrl = 'http://localhost:3000/init-stocks';
          final initStockResponse = await http.post(
            Uri.parse(initStockUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (initStockResponse.statusCode == 200) {
            final initStockBody = jsonDecode(initStockResponse.body);
            print('Stocks initialized: $initStockBody');

            // Display a success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Stocks successfully initialized')),
            );

            Navigator.pushReplacementNamed(context, '/stocks');
          } else {
            // Handle stock initialization failure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Stock initialization failed: ${initStockResponse.reasonPhrase}')),
            );
          }
        } else {
          print('Error: Missing token or userId in response');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-up failed: Invalid response')),
          );
        }
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User already exists. Please sign in.')),
        );
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        print('Sign-up failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-up failed: ${response.body}')),
        );
      }
    } catch (error) {
      print('Sign-up error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _isLoading
                ? const LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    color: Colors.blue,
                  )
                : ElevatedButton(
                    onPressed: () {
                      _signUp(context, emailController.text,
                          passwordController.text);
                    },
                    child: const Text('Sign Up'),
                  ),
          ],
        ),
      ),
    );
  }
}
