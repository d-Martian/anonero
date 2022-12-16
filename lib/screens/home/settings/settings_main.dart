import 'package:anon_wallet/channel/node_channel.dart';
import 'package:anon_wallet/screens/home/settings/export_wallet_backup.dart';
import 'package:anon_wallet/screens/home/settings/nodes/nodes_settings.dart';
import 'package:anon_wallet/screens/home/settings/proxy_settings.dart';
import 'package:anon_wallet/screens/home/settings/settings_state.dart';
import 'package:anon_wallet/screens/home/settings/view_wallet_private.dart';
import 'package:anon_wallet/screens/onboard/remote_node_setup.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    TextStyle? titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(color: Theme.of(context).primaryColor);
    Color? dividerColor = Colors.grey[700];
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text("Settings"),
            centerTitle: true,
          ),
          SliverPadding(padding: EdgeInsets.all(12)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text("Connection", style: titleStyle),
                ),
                Divider(color: dividerColor, height: 2),
                Opacity(
                  opacity: 0.4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 34),
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => const NodesSettingsScreens()));
                    },
                    title: const Text("Node"),
                  ),
                ),
                HookConsumer(builder: (context, ref, child) {
                  Proxy proxy = ref.watch(proxyStateProvider);
                  bool isConnected = ref.watch(connectionStatus);
                  useEffect(() {
                    ref.read(proxyStateProvider.notifier).getState();
                    ref.read(proxyStateProvider.notifier).getState();
                    return null;
                  }, []);
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProxySettings()));
                    },
                    title: const Text("Proxy"),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 34),
                    subtitle: proxy.isConnected()
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: isConnected
                                            ? Colors.green
                                            : dividerColor,
                                        fontSize: 11,
                                        wordSpacing: 0),
                                isConnected
                                    ? "Connected : ${proxy.serverUrl}:${proxy.port}"
                                    : "Disconnected : ${proxy.serverUrl}:${proxy.port}",
                              ),
                            ],
                          )
                        : Text("Disabled",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: dividerColor)),
                  );
                }),
                Divider(color: dividerColor, height: 2),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text("Security", style: titleStyle),
                ),
                Divider(color: dividerColor, height: 2),
                Opacity(
                  opacity: 0.4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 34),
                    onTap: () {},
                    title: const Text("Change Pin"),
                  ),
                ),
                Divider(color: dividerColor, height: 2),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 34),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ViewWalletSeed()));
                  },
                  title: const Text("View Seed"),
                ),
                Divider(color: dividerColor, height: 2),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 34),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ExportWalletBackUpScreen()));
                  },
                  title: const Text("Export Wallet"),
                ),
                Divider(color: dividerColor, height: 2),
                Opacity(
                  opacity: 0.4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 34),
                    onTap: () {},
                    title: const Text("Wallet Wipe"),
                  ),
                ),
                Divider(color: dividerColor, height: 2),
              ],
            ),
          )
        ],
      ),
    );
  }
}
