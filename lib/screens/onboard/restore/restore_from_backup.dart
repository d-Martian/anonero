import 'dart:async';
import 'dart:convert';

import 'package:anon_wallet/anon_wallet.dart';
import 'package:anon_wallet/channel/wallet_backup_restore_channel.dart';
import 'package:anon_wallet/models/backup.dart';
import 'package:anon_wallet/models/node.dart';
import 'package:anon_wallet/models/wallet.dart';
import 'package:anon_wallet/screens/home/settings/proxy_settings.dart';
import 'package:anon_wallet/screens/home/settings/settings_state.dart';
import 'package:anon_wallet/screens/onboard/onboard_state.dart';
import 'package:anon_wallet/screens/onboard/remote_node_setup.dart';
import 'package:anon_wallet/screens/set_pin_screen.dart';
import 'package:anon_wallet/state/node_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class RestoreFromBackup extends StatefulWidget {
  const RestoreFromBackup({Key? key}) : super(key: key);

  @override
  State<RestoreFromBackup> createState() => _RestoreFromBackupState();
}

class _RestoreFromBackupState extends State<RestoreFromBackup> {
  TextEditingController backupEditingController = TextEditingController();
  AnonBackupModel? walletBackUpModel;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: [
        Scaffold(
          body: Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: CustomScrollView(
              physics: NeverScrollableScrollPhysics(),
              slivers: [
                const SliverPadding(padding: EdgeInsets.only(top: 60)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                            tag: "anon_logo",
                            child: SizedBox(
                                width: 180,
                                child: Image.asset("assets/anon_logo.png"))),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TextField(
                      controller: backupEditingController,
                      textAlign: TextAlign.start,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      readOnly: false,
                      minLines: 5,
                      maxLines: 10,
                      obscuringCharacter: "*",
                      decoration: InputDecoration(
                          hintText: "Enter your backup data",
                          // suffixIcon: IconButton(
                          //   onPressed: () {
                          //     Clipboard.getData("text/plain").then((value) {
                          //       setState(() {
                          //         backupEditingController.text = value!.text!;
                          //       });
                          //     });
                          //   },
                          //   icon: const Icon(Icons.paste),
                          // ),
                          fillColor: Colors.grey[900],
                          filled: true,
                          enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                              borderSide:
                                  BorderSide(color: Colors.transparent)),
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                              borderSide:
                                  BorderSide(color: Colors.transparent)),
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                              borderSide:
                                  BorderSide(color: Colors.transparent)))),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            BackUpRestoreChannel()
                                .openBackUpFile()
                                .then((value) {
                              setState(() {
                                backupEditingController.text = value;
                              });
                            });
                          },
                          child: const Text("Open Backup File"),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: backupEditingController.text.isNotEmpty
                              ? Colors.white
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 6)),
                      onPressed: () async {
                        String passPhrase = await showPassphraseDialog(context);
                        Navigator.pop(context);
                        _parseBackup(passPhrase);
                      },
                      child: const Text("Validate Backup"),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Consumer(
          builder: (context, ref, c) {
            return BackupPreviewScreen(
                pageController: pageController,
                onButtonPressed: () {
                  String host =
                      "http://${walletBackUpModel!.node!.host}:${walletBackUpModel!.node!.rpcPort}";
                  if (walletBackUpModel?.node?.host == null) {
                    host = "";
                  }
                  ref.read(remoteHost.notifier).state = host;
                  ref.read(remoteUserName.notifier).state =
                      walletBackUpModel!.node?.username ?? "";
                  ref.read(remotePassword.notifier).state =
                      walletBackUpModel!.node?.password ?? "";
                  pageController.animateToPage(2,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                },
                walletBackUpModel: walletBackUpModel);
          },
        ),
        NodeSetup(
          pageController: pageController,
          onButtonPressed: () async {
            pageController.animateToPage(3,
                curve: Curves.easeInOutQuad,
                duration: const Duration(milliseconds: 500));
          },
        ),
        SetUpPin(
          onPinSet: (String pin) {
            pageController.animateToPage(4,
                curve: Curves.easeInOutQuad,
                duration: const Duration(milliseconds: 500));
            BackUpRestoreChannel().initiateRestore(pin);
          },
        ),
        Scaffold(
          body: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    Hero(
                        tag: "anon_logo",
                        child: SizedBox(
                            width: 160,
                            child: Image.asset("assets/anon_logo.png"))),
                  ],
                ),
                Padding(padding: EdgeInsets.all(12)),
                Text("Restoring wallet from backup"),
                Padding(padding: EdgeInsets.all(2)),
                Text(
                  "App will restart after restore",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<String> showPassphraseDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    FocusNode focusNode = FocusNode();
    Completer<String> completer = Completer();
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

  void _parseBackup(String passPhrase) async {
    String json = await BackUpRestoreChannel()
        .parseBackUp(backupEditingController.text, passPhrase);
    AnonBackupModel model = AnonBackupModel.fromJson(jsonDecode(json));
    setState(() {
      walletBackUpModel = model;
    });
    pageController.animateToPage(1,
        curve: Curves.easeInOutQuad,
        duration: const Duration(milliseconds: 500));
  }
}

class SetUpPin extends HookConsumerWidget {
  final Function(String pin) onPinSet;

  const SetUpPin({Key? key, required this.onPinSet}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = useState<String?>(null);
    final pageController = usePageController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Wallet PIN"),
      ),
      body: SizedBox.expand(
        child: Column(
          children: [
            Hero(
              tag: "anon_logo",
              child: SizedBox(
                  width: 180, child: Image.asset("assets/anon_logo.png")),
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 48, horizontal: 12),
                    child: NumberPadWidget(
                        maxPinSize: maxPinSize,
                        value: null,
                        minPinSize: minPinSize,
                        onSubmit: (String pin) {
                          value.value = pin;
                          pageController.animateToPage(1,
                              curve: Curves.easeInOutQuad,
                              duration: const Duration(milliseconds: 500));
                        }),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 48, horizontal: 12),
                    child: NumberPadWidget(
                        maxPinSize: maxPinSize,
                        value: value.value,
                        minPinSize: minPinSize,
                        onSubmit: (String pin) {
                          if (pin == value.value) {
                            onPinSet(pin);
                          }
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NodeSetup extends ConsumerWidget {
  final Function() onButtonPressed;
  final PageController pageController;

  const NodeSetup(
      {Key? key, required this.onButtonPressed, required this.pageController})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Node? node = ref.watch(nodeConnectionProvider);
    String? nodeMessage;
    if (node != null && node.responseCode <= 200) {
      nodeMessage = "Connected to ${node.host}\nHeight : ${node.height}";
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("Node Setup"),
            leading: IconButton(
              onPressed: () {
                pageController.animateToPage(1,
                    curve: Curves.easeInOutQuad,
                    duration: const Duration(milliseconds: 500));
              },
              icon: Icon(Icons.close),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("NODE",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary)),
              ),
              subtitle: Column(
                children: [
                  TextFormField(
                    onChanged: (value) {
                      ref.read(remoteHost.state).state = value;
                    },
                    initialValue: ref.read(remoteHost.state).state,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white, width: 1),
                      ),
                      helperText: nodeMessage,
                      helperMaxLines: 3,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'http://address.onion:port',
                    ),
                  ),
                  Consumer(builder: (context, ref, c) {
                    bool isConnecting =
                        ref.watch(connectingToNodeStateProvider);
                    if (isConnecting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: const LinearProgressIndicator(minHeight: 4)),
                      );
                    } else {
                      return const SizedBox();
                    }
                  })
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("USERNAME",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary)),
              ),
              subtitle: TextField(
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  ref.read(remoteUserName.state).state = value;
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: '(optional)',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("PASSWORD",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary)),
              ),
              subtitle: TextField(
                onChanged: (value) {
                  ref.read(remotePassword.state).state = value;
                },
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: '(optional)',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "ΛNON will only connect\nto the node specified above\n",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HookConsumer(
              builder: (c, ref, child) {
                Proxy proxy = ref.watch(proxyStateProvider);
                useEffect(() {
                  ref.read(proxyStateProvider.notifier).getState();
                  return null;
                }, []);
                return Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 24),
                  child: TextButton.icon(
                    style: ButtonStyle(
                        foregroundColor: proxy.isConnected()
                            ? MaterialStateColor.resolveWith(
                                (states) => Colors.green)
                            : MaterialStateColor.resolveWith(
                                (states) => Theme.of(context).primaryColor)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ProxySettings();
                        },
                      ));
                    },
                    label: Text("Proxy Settings"),
                    icon: Icon(Icons.shield_outlined),
                  ),
                );
              },
            ),
          ),
          SliverFillRemaining(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1.0, color: Colors.white),
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(width: 12, color: Colors.white),
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 6)),
                  onPressed: () async {
                    if (node != null) {
                      onButtonPressed();
                      return;
                    }
                    ref.read(nodeConnectionProvider.notifier).connect();
                  },
                  child: Text(node == null ? "Connect" : "Next"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackupPreviewScreen extends StatelessWidget {
  final PageController pageController;
  final Function() onButtonPressed;
  final AnonBackupModel? walletBackUpModel;

  const BackupPreviewScreen(
      {Key? key,
      required this.walletBackUpModel,
      required this.onButtonPressed,
      required this.pageController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    WalletBackupModel? backupModel = walletBackUpModel?.wallet;
    NodeBackupModel? nodeBackupModel = walletBackUpModel?.node;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Backup Preview"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              pageController.animateToPage(0,
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 500));
            },
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: backupModel != null
                  ? _buildWalletDetails(backupModel, context)
                  : const SizedBox(),
            ),
            SliverToBoxAdapter(
              child: nodeBackupModel != null
                  ? _buildNodeDetails(nodeBackupModel, context)
                  : const SizedBox(),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Text("${formatTime(walletBackUpModel?.meta?.timestamp)}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[300], fontWeight: FontWeight.w700)),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.all(20)),
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1.0, color: Colors.white),
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(width: 12, color: Colors.white),
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 6)),
                  onPressed: onButtonPressed,
                  child: const Text("Setup Node"),
                ),
              ),
            )
          ],
        ));
  }

  _buildWalletDetails(WalletBackupModel model, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.6),
              width: 1)),
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(4)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Text("Wallet Details",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 15)),
          ),
          Divider(
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          ListTile(
            title: Text("Primary Address",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "${model.address}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          ListTile(
            title: Text("Seed",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "${model.seed}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          ListTile(
            title: Text("No of Sub-addresses",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "${model.numSubaddresses}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          Row(
            children: [
              Flexible(
                child: ListTile(
                  title: Text("Total Balance",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "${formatMonero(model.balanceAll)} XMR",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListTile(
                  title: Text("Restore Height",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "${model.restoreHeight}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.all(6))
        ],
      ),
    );
  }

  formatTime(num? timestamp) {
    if (timestamp == null) {
      return "";
    }
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    return DateFormat("yyy-MM-dd  H:mm dd/M").format(dateTime);
  }

  _buildNodeDetails(NodeBackupModel model, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.6),
              width: 1)),
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(4)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Text("Node Details",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 15)),
          ),
          Divider(
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          ListTile(
            title: Text("Node Address",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "${model.host}:${model.rpcPort}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(6))
        ],
      ),
    );
  }
}
