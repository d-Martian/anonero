import 'dart:async';
import 'dart:convert';

import 'package:anon_wallet/channel/wallet_backup_restore_channel.dart';
import 'package:anon_wallet/models/backup.dart';
import 'package:anon_wallet/screens/onboard/onboard_screen.dart';
import 'package:anon_wallet/screens/onboard/onboard_state.dart';
import 'package:anon_wallet/screens/onboard/restore/restore_from_backup.dart';
import 'package:anon_wallet/state/node_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
                          width: MediaQuery.of(context).size.width / 0.7,
                          child: Image.asset("assets/anon_logo.png"))),
                ],
              )),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Consumer(
                  builder: (context, ref, c) {
                    var existingNode = ref.watch(nodeFromPrefs);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white),
                      onPressed: () async {
                        ref.read(remoteUserName.notifier).state = "";
                        ref.read(remotePassword.notifier).state = "";
                        ref.read(remoteHost.notifier).state = "";
                        ref.read(navigatorState.notifier).state = 0;
                        ref.read(walletSeedPhraseProvider.notifier).state = "";
                        ref.read(walletLockPin.notifier).state = "";
                        if (existingNode.hasValue &&
                            existingNode.value != null) {
                          ref.read(remoteHost.notifier).state =
                              existingNode.value!.toNodeString();
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
                                  builder: (c) => OnboardScreen(),
                                  settings: RouteSettings()));
                        } catch (e, s) {
                          debugPrintStack(stackTrace: s);
                        }
                      },
                      child: Text("CREATE WALLET",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700)),
                    );
                  },
                ),
                const Padding(padding: EdgeInsets.all(12)),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white),
                      onPressed: () {
                        showRestoreOptions(context);
                      },
                      child: Text("RESTORE WALLET",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }

  void showRestoreOptions(BuildContext context) {
    TextEditingController controller = TextEditingController();
    FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (_) {
        return HookBuilder(
          builder: ((context) {
            ValueNotifier<bool> loadingFile = useState(false);
            ValueNotifier<String?> backupContent = useState(null);
            PageController pageController = usePageController();
            return PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                          tag: "anon_logo",
                          child: SizedBox(
                              width: 84,
                              child: Image.asset("assets/anon_logo.png"))),
                      Text("Restore"),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          try {
                            loadingFile.value = true;
                            String value =
                                await BackUpRestoreChannel().openBackUpFile();
                            backupContent.value = value;
                            loadingFile.value = false;
                            pageController.animateToPage(1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInSine);
                          } catch (e) {
                            loadingFile.value = false;
                            Navigator.pop(context);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            loadingFile.value
                                ? const SizedBox(
                                    child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: SizedBox.square(
                                      dimension: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  ))
                                : const SizedBox.shrink(),
                            Text(!loadingFile.value
                                ? "Restore from anon backup"
                                : "Reading file..."),
                          ],
                        )),
                    Divider(),
                    Opacity(
                      opacity: 0.5,
                      child: TextButton(
                          onPressed: () {}, child: Text("Restore from seed")),
                    ),
                    Padding(padding: EdgeInsets.all(12))
                  ],
                  actionsOverflowDirection: VerticalDirection.down,
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actionsOverflowAlignment: OverflowBarAlignment.center,
                ),
                HookBuilder(
                  builder: (context) {
                    const inputBorder = UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent));
                    var error = useState<String?>(null);
                    var loading = useState<bool>(false);
                    useEffect(() {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        focusNode.requestFocus();
                      });
                      return null;
                    }, []);
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 28),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enter Passphrase",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Padding(padding: EdgeInsets.all(12)),
                            TextField(
                                focusNode: focusNode,
                                controller: controller,
                                textAlign: TextAlign.center,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                obscuringCharacter: "*",
                                decoration: InputDecoration(
                                    errorText: error.value,
                                    fillColor: Colors.grey[900],
                                    filled: true,
                                    focusedBorder: inputBorder,
                                    border: inputBorder,
                                    errorBorder: inputBorder)),
                            loading.value
                                ? const LinearProgressIndicator(
                                    minHeight: 1,
                                  )
                                : const SizedBox()
                          ],
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                              tag: "anon_logo",
                              child: SizedBox(
                                  width: 84,
                                  child: Image.asset("assets/anon_logo.png"))),
                          const Text("Restore"),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel")),
                        TextButton(
                            onPressed: () async {
                              if (!controller.text.isEmpty &&
                                  backupContent.value != null) {
                                String decrypted = await BackUpRestoreChannel()
                                    .parseBackUp(
                                        backupContent.value!, controller.text);
                                AnonBackupModel model =
                                    AnonBackupModel.fromJson(
                                        jsonDecode(decrypted));
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => RestoreFromBackup(
                                            anonBackupModel: model)));
                              } else {
                                Navigator.pop(context);
                                return;
                              }
                            },
                            child: const Text("Confirm"))
                      ],
                    );
                  },
                )
              ],
            );
          }),
        );
      },
      barrierDismissible: true,
      barrierColor: const Color(0xab1e1e1e),
    );
    return;
  }

  Future<String?> showPassphraseDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    FocusNode focusNode = FocusNode();
    Completer<String?> completer = Completer();
    showDialog(
        context: context,
        barrierColor: barrierColor,
        barrierDismissible: false,
        builder: (context) {
          return HookBuilder(
            builder: (context) {
              const inputBorder = UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent));
              var error = useState<String?>(null);
              var loading = useState<bool>(false);
              useEffect(() {
                focusNode.requestFocus();
                return null;
              }, []);
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Passphrase",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Padding(padding: EdgeInsets.all(12)),
                      TextField(
                          focusNode: focusNode,
                          controller: controller,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          obscuringCharacter: "*",
                          decoration: InputDecoration(
                              errorText: error.value,
                              fillColor: Colors.grey[900],
                              filled: true,
                              focusedBorder: inputBorder,
                              border: inputBorder,
                              errorBorder: inputBorder)),
                      loading.value
                          ? const LinearProgressIndicator(
                              minHeight: 1,
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        completer.complete(null);
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () async {
                        completer.complete(controller.text);
                      },
                      child: const Text("Confirm"))
                ],
              );
            },
          );
        });
    return completer.future;
  }
}
