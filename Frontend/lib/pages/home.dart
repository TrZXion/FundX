import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_app/pages/signup.dart';
import 'package:test_app/pages/stocks.dart'; // Ensure this import is correct
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Define the function to store the token and user ID
Future<void> storeTokenAndUserId(String token, int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setInt('userId', userId);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isAuthenticated = false;
  bool _isLoading = false; // Loading state

  Future<void> _signIn(String email, String password) async {
    const url = 'http://localhost:3000/signin'; // Update to your backend URL

    setState(() {
      _isLoading = true; // Start loading
    });

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

        // Store the token or any authentication status
        setState(() {
          _isAuthenticated = true;
          _isLoading = false; // Stop loading
        });

        await storeTokenAndUserId(token, userId);

        // Navigate to the main page or dashboard
        Navigator.pushReplacementNamed(context, '/stocks');
      } else {
        // Handle error
        setState(() {
          _isLoading = false; // Stop loading
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: ${response.body}')),
        );
      }
    } catch (error) {
      // Handle network error
      setState(() {
        _isLoading = false; // Stop loading
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FundX',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0.0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(5),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icons/growth-svgrepo-com.svg',
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(5),
            alignment: Alignment.center,
            width: 50,
            child: SvgPicture.asset(
              'assets/icons/avatar.svg',
              height: 50,
              width: 50,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.blueGrey.shade800, // Set background color here
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sign In Section
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Colors.grey[900], // Background color for the text field
                labelText: 'Email',
                labelStyle:
                    const TextStyle(color: Colors.white), // Label text color
                hintText: 'Enter your email',
                hintStyle:
                    const TextStyle(color: Colors.white60), // Hint text color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  borderSide: BorderSide.none, // No border side
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12), // Padding inside the text field
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white), // Text color
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Colors.grey[900], // Background color for the text field
                labelText: 'Password',
                labelStyle:
                    const TextStyle(color: Colors.white), // Label text color
                hintText: 'Enter your password',
                hintStyle:
                    const TextStyle(color: Colors.white60), // Hint text color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  borderSide: BorderSide.none, // No border side
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12), // Padding inside the text field
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white), // Text color
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _signIn(emailController.text, passwordController.text);
              },
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Sign In'),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to forgot password page
                      Navigator.pushNamed(context,
                          '/forgot-password'); // Ensure this route is set up
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey[800], // Background color
                      onPrimary: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                    child: const Text('Forgot Password'),
                  ),
                ),
                const SizedBox(width: 8.0), // Space between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey[800], // Background color
                      onPrimary: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            // ElevatedButton(
            //   onPressed: _isAuthenticated
            //       ? () {
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => const StocksPage(),
            //             ),
            //           );
            //         }
            //       : null, // Disable button if not authenticated
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.lightGreen.shade900, // Background color
            //     onPrimary: Colors.white, // Text color
            //     minimumSize: const Size(75, 50), // Size of the button
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(30), // Rounded corners
            //     ),
            //     padding: const EdgeInsets.symmetric(
            //         vertical: 12), // Padding inside the button
            //   ),
            //   child: const Text('Go to Stocks', style: TextStyle(fontSize: 16)),
            // ),
          ],
        ),
      ),
    );
  }
}
