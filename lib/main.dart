import 'package:anon_wallet/anon_wallet.dart';
import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/channel/wallet_events_channel.dart';
import 'package:anon_wallet/models/wallet.dart';
import 'package:anon_wallet/screens/home/wallet_home.dart';
import 'package:anon_wallet/screens/landing_screen.dart';
import 'package:anon_wallet/screens/set_pin_screen.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
      home: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
        title: 'anon',
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
  Widget build(BuildContext context, ref) {
    return state == WalletState.walletReady ? const LockScreen() : const LandingScreen();
  }
}

class LockScreen extends HookWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final error = useState<String?>(null);
    final loading = useState<bool>(false);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: loading.value ? const LinearProgressIndicator() : null,
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Hero(
            tag: "anon_logo",
            child: SizedBox(width: 180, child: Image.asset("assets/anon_logo.png")),
          ),
          const Text("Please enter your pin"),
          const Padding(padding: EdgeInsets.symmetric(vertical: 6)),
          AnimatedOpacity(opacity: error.value == null ? 0 : 1, duration: Duration(milliseconds: 300), child: Text(
            error.value ?? "",
            style: Theme
                .of(context)
                .textTheme
                .subtitle2
                ?.copyWith(color: Colors.red),
          ),),
          const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Consumer(
                builder: (context, ref, c) {
                  return NumberPadWidget(
                    maxPinSize: maxPinSize,
                    onKeyPress: (s){
                      error.value = null;
                    },
                    minPinSize: minPinSize,
                    onSubmit: (String pin) {
                      onSubmit(pin, context, ref, error, loading);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onSubmit(String pin, BuildContext context, WidgetRef ref, ValueNotifier<String?> error,
      ValueNotifier<bool> loading) async {
    try {
      error.value = null;
      loading.value = true;
      Wallet? wallet = await WalletChannel().openWallet(pin);
      WalletChannel().startSync();
      WalletEventsChannel().initEventChannel();
      loading.value = false;
      if (wallet != null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => WalletHome()), (route) => false);
      }
    } on PlatformException catch (e) {
      error.value = e.message;
    } catch (e) {
      print(e);
    } finally {
      loading.value = false;
    }
  }
}
