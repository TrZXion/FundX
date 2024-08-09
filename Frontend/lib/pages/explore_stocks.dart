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
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('stocks_data');

    if (storedData != null) {
      setState(() {
        _stocks = jsonDecode(storedData);
        _isLoading = false;
      });
    } else {
      _fetchStockData();
    }
  }

  Future<void> _fetchStockData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User is not authenticated. Please log in.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    const url = 'http://localhost:3000/stocks'; // Update URL as needed

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse is List) {
          await prefs.setString('stocks_data', response.body);

          setState(() {
            _stocks = decodedResponse;
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load stock data: ${response.reasonPhrase}')),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStockData, // Refresh the stock data
          ),
        ],
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
                          Text(
                            symbol,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${currentPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
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
