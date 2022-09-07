import 'package:anon_wallet/models/wallet.dart';
import 'package:anon_wallet/screens/home/wallet_home.dart';
import 'package:anon_wallet/screens/onboard/onboard_state.dart';
import 'package:anon_wallet/screens/onboard/polyseed_widget.dart';
import 'package:anon_wallet/screens/onboard/remote_node_setup.dart';
import 'package:anon_wallet/screens/onboard/wallet_passphrase.dart';
import 'package:anon_wallet/screens/set_pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OnboardScreen extends ConsumerStatefulWidget {
  const OnboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends ConsumerState<OnboardScreen> {
  PageController pageController = PageController();
  int currentPage = 0;
  String page = "NODE CONNECTION";
  String seedPassPhrase = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pageController.addListener(() {
        if (pageController.page != null) {
          ref.read(navigatorState.notifier).state = pageController.page!.toInt();
        }
        setState(() {
          if (pageController.page == 0) {
            page = "NODE CONNECTION";
          }
          if (pageController.page == 1) {
            page = "ENTER PASSPHRASE FOR MNEMONIC";
          }
          if (pageController.page == 2) {
            page = "POLYSEED MNEMONIC";
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Wallet? wallet = ref.watch(newWalletProvider);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                const RemoteNodeWidget(),
                WalletPassphraseWidget(
                  onPassSeedPhraseAdded: (value) {
                    ref.read(walletSeedPhraseProvider.state).state = value;
                  },
                ),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 26),
                    child: PolySeedWidget(seedWords: wallet == null ? [] : wallet.seed)),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, c) {
              var value = ref.watch(nextButtonValidation);
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.white),
                  onPressed: value
                      ? () async {
                          onNext(context);
                        }
                      : null,
                  child: Text(pageController.page == 2 ? "Finish" : "Next",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  onNext(BuildContext context) async {
    if (pageController.page == 1) {
      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(const Duration(milliseconds: 200));
      String? pin = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return const SetPinScreen();
          },
          fullscreenDialog: true));
      if (pin != null) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  content: SizedBox(
                    height: 60,
                    child: Column(children: [
                      const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 8)),
                      Text(
                        "Please wait,wallet is creating...",
                        style: Theme.of(context).textTheme.caption,
                      )
                    ]),
                  ));
            });
        await ref.read(newWalletProvider.notifier).createWallet(pin);
        Navigator.pop(context);
        pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOutSine);
      }
    } else {
      if (pageController.page == 2) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (c) {
            return const WalletHome();
          }),
          (route) => false,
        );
        return;
      }
      pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOutSine);
    }
  }
}
