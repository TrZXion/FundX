import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreStocksPage extends StatefulWidget {
  const ExploreStocksPage({Key? key}) : super(key: key);

  @override
  _ExploreStocksPageState createState() => _ExploreStocksPageState();
}

class _ExploreStocksPageState extends State<ExploreStocksPage> {
  List<dynamic> _stocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStockData(); // Load data from SharedPreferences
  }

  Future<void> _loadStockData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('stocks_data');

    if (storedData != null) {
      // Load data from SharedPreferences
      setState(() {
        _stocks = jsonDecode(storedData);
        _isLoading = false;
      });
    } else {
      // Fetch data from API
      _fetchStockData();
    }
  }

  Future<void> _fetchStockData() async {
    const userId =
        4; // Replace with actual user ID or fetch from your auth logic
    const url = 'http://localhost:3000/stocks/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Save data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('stocks_data', response.body);

        setState(() {
          _stocks = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load stock data: ${response.body}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text('Explore Stocks', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stocks.isEmpty
              ? const Center(
                  child: Text('No stocks available',
                      style: TextStyle(color: Colors.white)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _stocks.length,
                  itemBuilder: (context, index) {
                    final stock = _stocks[index];

                    if (stock == null) {
                      return Container(); // Skip this item if it's null
                    }

                    final symbol = stock['symbol'] ?? 'Unknown';
                    final currentPrice = stock['c'] ?? 0.0;
                    final priceChange = stock['d'] ?? 0.0;
                    final priceChangePercent = stock['dp'] ?? 0.0;
                    final isPositiveChange = priceChange >= 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Stock name on the left side
                          Text(
                            symbol,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                          // Current price and change info on the right side
                          Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .end, // Align text to the right
                            children: [
                              Text(
                                '\$${currentPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(
                                  height:
                                      8), // Space between price and change info
                              Text(
                                '${isPositiveChange ? '+' : ''}${priceChange.toStringAsFixed(2)} (${priceChangePercent.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color: isPositiveChange
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
