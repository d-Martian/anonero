import 'package:anon_wallet/channel/node_channel.dart';
import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/channel/wallet_events_channel.dart';
import 'package:anon_wallet/models/node.dart';
import 'package:anon_wallet/screens/onboard/onboard_screen.dart';
import 'package:anon_wallet/screens/onboard/onboard_state.dart';
import 'package:anon_wallet/screens/onboard/restore/restore_screen.dart';
import 'package:anon_wallet/screens/set_pin_screen.dart';
import 'package:anon_wallet/state/node_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                      tag: "anon_logo",
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width / 0.7, child: Image.asset("assets/anon_logo.png"))),
                ],
              )),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Consumer(
                  builder: (context,ref,c){
                    var existingNode = ref.watch(nodeFromPrefs);
                    return  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white),
                      onPressed: () async {
                        ref.read(remoteUserName.notifier).state = "";
                        ref.read(remotePassword.notifier).state = "";
                        ref.read(remoteHost.notifier).state = "";
                        ref.read(navigatorState.notifier).state = 0;
                        ref.read(walletSeedPhraseProvider.notifier).state = "";
                        ref.read(walletLockPin.notifier).state = "";
                        if(existingNode.hasValue && existingNode.value !=null){
                          ref.read(remoteHost.notifier).state = existingNode.value!.toNodeString();
                        }
                        // showDialog(
                        //     context: context,
                        //     builder: (context) {
                        //       return AlertDialog(
                        //           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        //           content: SizedBox(
                        //             height: 60,
                        //             child: Column(children: [
                        //               const Center(
                        //                 child: CircularProgressIndicator(
                        //                   strokeWidth: 1,
                        //                 ),
                        //               ),
                        //               const Padding(padding: EdgeInsets.only(bottom: 8)),
                        //               Text(
                        //                 "Please wait,wallet is creating...",
                        //                 style: Theme.of(context).textTheme.caption,
                        //               )
                        //             ]),
                        //           ));
                        //     });
                        try {
                          // if(pin == null){
                          //   return;
                          // }
                          // var wallet = await WalletChannel().create(pin);
                          // wallet.pin = pin;
                          // Navigator.pop(context);
                          // wallet.seed = "scorpion enough attitude image mountain off stem head this quick vivid defy exotic reveal type monitor crash mosquito universe oxygen clap wedding vocal labor".split(" ");
                          // await Future.delayed(Duration(milliseconds: 120));
                          // NodeChannel().testRPC();

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => OnboardScreen(), settings: RouteSettings()));
                        } catch (e, s) {
                          debugPrintStack(stackTrace: s);
                        }
                      },
                      child: Text("CREATE WALLET",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
                    );
                  },
                ),
                const Padding(padding: EdgeInsets.all(12)),
                Column(
                  children: const [
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(primary: Colors.white),
                    //   onPressed: () {
                    //     Navigator.push(context, MaterialPageRoute(builder: (c) => const RestoreScreen()));
                    //   },
                    //   child: Text("RESTORE WALLET",
                    //       style: Theme.of(context)
                    //           .textTheme
                    //           .labelLarge
                    //           ?.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
                    // ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
