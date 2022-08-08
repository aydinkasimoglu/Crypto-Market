import 'dart:collection';

import 'package:crypto_market/screens/coins_page.dart';
import 'package:crypto_market/screens/wallet_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  static final Map<String, double> _savedCurrencies = HashMap();
  static final List<Widget> _screens = <Widget>[
    CoinsPage(savedCurrencies: _savedCurrencies,),
    WalletPage(savedCurrencies: _savedCurrencies,)
  ];
  static const List<String> _screenTitles = <String>[
    "Crypto Market",
    "My Wallet"
  ];

  void onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles.elementAt(_selectedNavIndex)),
      ),
      body: _screens.elementAt(_selectedNavIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'Coins'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet')
        ],
        currentIndex: _selectedNavIndex,
        onTap: onNavItemTapped,
      ),
    );
  }
}
