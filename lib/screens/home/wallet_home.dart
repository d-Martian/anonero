import 'package:anon_wallet/screens/home/receive_screen.dart';
import 'package:anon_wallet/screens/home/transactions/transactions_list.dart';
import 'package:anon_wallet/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';

class WalletHome extends StatefulWidget {
  const WalletHome({Key? key}) : super(key: key);

  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  int _currentView = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          const TransactionsList(),
          ReceiveWidget(() {
            _pageController.animateToPage(0, duration: const Duration(milliseconds: 220), curve: Curves.ease);
          }),
          Container(color: Colors.grey.shade700),
          Container(color: Colors.grey.shade900),
        ],
        onPageChanged: (index) {
          setState(() => _currentView = index);
        },
      ),
      bottomNavigationBar: BottomBar(
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedIndex: _currentView,
        onTap: (int index) {
          setState(() => _currentView = index);
          _pageController.animateToPage(index, duration: Duration(milliseconds: 120), curve: Curves.ease);
        },
        items: <BottomBarItem>[
          BottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text('Home'),
            activeColor: Theme
                .of(context)
                .primaryColor,
          ),
          BottomBarItem(
            icon: const Icon(Icons.qr_code),
            title: const Text('Receive'),
            activeColor: Theme
                .of(context)
                .primaryColor,
          ),
          BottomBarItem(
            icon: const Icon(Icons.send_outlined),
            title: const Text('Send'),
            activeColor: Theme
                .of(context)
                .primaryColor,
          ),
          BottomBarItem(
            icon: const Icon(Icons.settings),
            title: const Text('Settings'),
            activeColor: Theme
                .of(context)
                .primaryColor,
          ),
        ],
      ),
    );
  }
}
