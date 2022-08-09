import 'package:crypto_market/screens/coins_page.dart';
import 'package:crypto_market/screens/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

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
  static final List<Widget> _screens = <Widget>[
    const CoinsPage(),
    const WalletPage(),
  ];
  static const List<String> _screenTitles = <String>[
    "Crypto Market",
    "My Wallet"
  ];

  /// Handle the navigation bar selection.
  /// This is called when the user taps on the navigation item.
  void onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Change the title based on the nav item selected.
        title: Text(_screenTitles.elementAt(_selectedNavIndex)),
      ),
      // Change the body based on the nav item selected.
      body: _screens.elementAt(_selectedNavIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.currency_bitcoin), label: 'Coins'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet')
        ],
        currentIndex: _selectedNavIndex,
        onTap: onNavItemTapped,
      ),
    );
  }
}
