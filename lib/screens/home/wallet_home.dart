import 'dart:io';

import 'package:anon_wallet/channel/wallet_events_channel.dart';
import 'package:anon_wallet/models/node.dart';
import 'package:anon_wallet/screens/home/receive_screen.dart';
import 'package:anon_wallet/screens/home/settings/settings_main.dart';
import 'package:anon_wallet/screens/home/spend/spend_screen.dart';
import 'package:anon_wallet/screens/home/spend/spend_state.dart';
import 'package:anon_wallet/screens/home/transactions/transactions_list.dart';
import 'package:anon_wallet/state/node_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:anon_wallet/utils/app_haptics.dart';
import 'package:anon_wallet/utils/parsers.dart';
import 'package:anon_wallet/widgets/bottom_bar.dart';
import 'package:anon_wallet/widgets/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WalletHome extends ConsumerStatefulWidget {
  const WalletHome({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends ConsumerState<WalletHome> {
  int _currentView = 0;
  final PageController _pageController = PageController();
  GlobalKey scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page == 0) {
          return await showDialog(
              context: context,
              barrierColor: barrierColor,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  content: const Text("Do you want to exit the app ?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text("No")),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          SystemNavigator.pop(animated: true);
                        },
                        child: const Text("Yes")),
                  ],
                );
              });
        } else {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 220), curve: Curves.ease);
        }
        return false;
      },
      child: Scaffold(
        key: scaffoldState,
        body: PageView(
          controller: _pageController,
          children: [
            Builder(
              builder: (context) {
                return TransactionsList(
                  onScanClick: () {
                    showBottomSheet(
                        context: context,
                        builder: (context) {
                          return Consumer(
                            builder: (context, ref, c) {
                              return QRScannerView(
                                onScanCallback: (value) {
                                  AppHaptics.lightImpact();
                                  var parsedAddress =
                                      Parser.parseAddress(value);
                                  if (parsedAddress[0] != null) {
                                    ref.read(addressStateProvider.state).state =
                                        parsedAddress[0];
                                  }
                                  if (parsedAddress[1] != null) {
                                    ref.read(amountStateProvider.state).state =
                                        parsedAddress[1];
                                  }
                                  if (parsedAddress[2] != null) {
                                    ref.read(notesStateProvider.state).state =
                                        parsedAddress[2];
                                  }
                                  _pageController.animateToPage(2,
                                      duration:
                                          const Duration(milliseconds: 220),
                                      curve: Curves.ease);
                                },
                              );
                            },
                          );
                        });
                  },
                );
              },
            ),
            ReceiveWidget(() {
              _pageController.animateToPage(0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.ease);
            }),
            const SpendScreen(),
            const SettingsScreen(),
          ],
          onPageChanged: (index) {
            setState(() => _currentView = index);
          },
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            ref.listen<String?>(nodeErrorState,
                (String? previousCount, String? newValue) {
              if (newValue != null && scaffoldState.currentContext != null) {
                ScaffoldMessenger.of(scaffoldState.currentContext!)
                    .showMaterialBanner(
                        MaterialBanner(content: Text(newValue), actions: [
                  TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .hideCurrentMaterialBanner();
                      },
                      child: const Text("Close"))
                ]));
              } else {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              }
            });
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: BottomBar(
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          selectedIndex: _currentView,
          onTap: (int index) {
            setState(() => _currentView = index);
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 120), curve: Curves.ease);
          },
          items: <BottomBarItem>[
            BottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text('Home'),
              activeColor: Theme.of(context).primaryColor,
            ),
            BottomBarItem(
              icon: const Icon(Icons.qr_code),
              title: const Text('Receive'),
              activeColor: Theme.of(context).primaryColor,
            ),
            BottomBarItem(
              icon: const Icon(Icons.send_outlined),
              title: const Text('Send'),
              activeColor: Theme.of(context).primaryColor,
            ),
            BottomBarItem(
              icon: const Icon(Icons.settings),
              title: const Text('Settings'),
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
