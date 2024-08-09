import 'package:flutter/material.dart';
import 'package:test_app/pages/explore_stocks.dart';
// ignore: unnecessary_import
import 'package:test_app/pages/home.dart';
import 'package:test_app/pages/signup.dart';
import 'package:test_app/pages/stocks.dart'; // Import the StocksPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: '/', // Set initial route
      routes: {
        '/': (context) => const HomePage(),
        '/sign-up': (context) => const SignUpPage(),
        '/stocks': (context) => const StocksPage(), // Add the StocksPage route
        '/explore-stocks': (context) =>
            const ExploreStocksPage(), // Add the ExploreStocksPage route
      },
    );
  }
}
