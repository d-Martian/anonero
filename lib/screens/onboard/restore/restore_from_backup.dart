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
import 'package:anon_wallet/screens/onboard/restore/restore_node_setup.dart';
import 'package:anon_wallet/screens/set_pin_screen.dart';
import 'package:anon_wallet/state/node_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class RestoreFromBackup extends StatefulWidget {
  final AnonBackupModel? anonBackupModel;

  const RestoreFromBackup({Key? key, this.anonBackupModel}) : super(key: key);

  @override
  State<RestoreFromBackup> createState() => _RestoreFromBackupState();
}

class _RestoreFromBackupState extends State<RestoreFromBackup> {
  TextEditingController backupEditingController = TextEditingController();
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: [
        Consumer(
          builder: (context, ref, c) {
            AnonBackupModel? walletBackUpModel = widget.anonBackupModel;
            if (walletBackUpModel == null) {
              return const Scaffold(
                body: Center(
                  child: Text("Unable to parse backup..."),
                ),
              );
            }
            return BackupPreviewScreen(
                pageController: pageController,
                onButtonPressed: () {
                  String host =
                      "http://${widget.anonBackupModel!.node!.host}:${widget.anonBackupModel!.node!.rpcPort}";
                  if (widget.anonBackupModel?.node?.host == null) {
                    host = "";
                  }
                  ref.read(remoteHost.notifier).state = host;
                  ref.read(remoteUserName.notifier).state =
                      walletBackUpModel.node?.username ?? "";
                  ref.read(remotePassword.notifier).state =
                      walletBackUpModel.node?.password ?? "";
                  pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                },
                walletBackUpModel: walletBackUpModel);
          },
        ),
        RestoreNodeSetup(
          pageController: pageController,
          onButtonPressed: () async {
            pageController.animateToPage(3,
                curve: Curves.easeInOutQuad,
                duration: const Duration(milliseconds: 500));
            await BackUpRestoreChannel().initiateRestore();
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
            icon: const Icon(Icons.close),
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
