import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class StocksPage extends StatelessWidget {
  const StocksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Stocks', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('icons/avatar.png'),
            ),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('NIFTY 50', '24,297.50', '+304.95 (1.27%)'),
                _buildStatCard('BANK NIFTY', '50,119.00', '+370.70 (0.75%)'),
              ],
            ),
            const SizedBox(height: 16),
            // Row with buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _buildButton('Explore stocks', () {
                    Navigator.pushNamed(context, '/explore-stocks');
                  }),
                  flex: 1,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: _buildButton('Holdings', () {}),
                  flex: 1,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: _buildButton('My WatchList', () {}),
                  flex: 1,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: _buildButton('+ Watchlist', () {}),
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Most bought on Groww'),
            const SizedBox(height: 8),
            Expanded(
              child: _buildStockGrid(),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Product & Tools'),
            const SizedBox(height: 8),
            Expanded(
              child: _buildProductToolsGrid(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Stocks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Mutual Funds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Loans',
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');

    // Navigate to the HomePage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false, // Remove all previous routes
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout(context); // Perform logout
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.grey[900],
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 4),
          Text(change, style: const TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: const TextStyle(color: Colors.white, fontSize: 18));
  }

  Widget _buildStockGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return _buildStockCard(
                'IRFC', '₹182.41', '+6.05 (3.43%)', 'assets/icons/irfc.svg');
          case 1:
            return _buildStockCard('Zomato', '₹265.67', '+16.59 (6.66%)',
                'assets/icons/zomato.svg');
          case 2:
            return _buildStockCard('Tata Steel', '₹153.86', '+3.54 (2.35%)',
                'assets/icons/tata.svg');
          case 3:
            return _buildStockCard(
                'SBI', '₹202.77', '+0.13 (4.92%)', 'assets/icons/sbi.svg');
          default:
            return Container();
        }
      },
    );
  }

  Widget _buildStockCard(
      String name, String price, String change, String iconPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (iconPath.endsWith('.svg'))
            SvgPicture.asset(iconPath, height: 40, width: 40)
          else
            Image.asset(iconPath, height: 40, width: 40),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text(price,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 4),
          Text(change, style: const TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildProductToolsGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      children: [
        _buildProductToolCard('F&O', 'assets/icons/fno.png'),
        _buildProductToolCard('Events', 'assets/icons/event.png'),
        _buildProductToolCard('IPO', 'assets/icons/ipo.png'),
        _buildProductToolCard('All Stocks', 'assets/icons/all_stocks.png'),
      ],
    );
  }

  Widget _buildProductToolCard(String name, String iconPath) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 40, width: 40),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
