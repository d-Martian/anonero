import 'package:anon_wallet/anon_wallet.dart';
import 'package:anon_wallet/channel/node_channel.dart';
import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/channel/wallet_events_channel.dart';
import 'package:anon_wallet/models/wallet.dart';
import 'package:anon_wallet/screens/home/wallet_home.dart';
import 'package:anon_wallet/screens/landing_screen.dart';
import 'package:anon_wallet/screens/set_pin_screen.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  runApp(const SplashScreen());
  WalletState state = await WalletChannel().getWalletState();
  runApp(AnonApp(state));
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeProvider().getTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("LOADING"),
        ),
        body: const CircularProgressIndicator(),
      ),
    );
  }
}

class AnonApp extends StatefulWidget {
  final WalletState state;

  const AnonApp(this.state, {Key? key}) : super(key: key);

  @override
  State<AnonApp> createState() => _AnonAppState();
}

class _AnonAppState extends State<AnonApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeProvider().getTheme(),
        home: AppMain(this.widget.state),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WalletEventsChannel();
  }
}

class AppMain extends ConsumerWidget {
  final WalletState state;
  const AppMain(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,ref) {
    return state == WalletState.walletReady ? const LockScreen() : const LandingScreen();
  }
}



class LockScreen extends StatelessWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Hero(
            tag: "anon_logo",
            child: SizedBox(width: 240, child: Image.asset("assets/anon_logo.png")),
          ),
          const Text("Please enter your pin"),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24)),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Consumer(
                builder: (context,ref,c){
                  return NumberPadWidget(
                    maxPinSize: maxPinSize,
                    minPinSize: minPinSize,
                    onSubmit: (String pin) {
                      onSubmit(pin, context,ref);
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void onSubmit(String pin, BuildContext context,WidgetRef ref) async {
    try {
      Wallet? wallet = await WalletChannel().openWallet(pin);
      WalletChannel().startSync();
      if (wallet != null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => WalletHome()), (route) => false);
      }
    } catch (e) {
      print(e);
    }
  }
}
