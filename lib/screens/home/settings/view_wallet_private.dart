import 'package:anon_wallet/models/wallet.dart';
import 'package:anon_wallet/screens/home/settings/settings_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:anon_wallet/utils/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ViewWalletSeed extends ConsumerStatefulWidget {
  const ViewWalletSeed({Key? key}) : super(key: key);

  @override
  ConsumerState<ViewWalletSeed> createState() => _ViewWalletSeedState();
}

class _ViewWalletSeedState extends ConsumerState<ViewWalletSeed> {
  @override
  Widget build(BuildContext context) {
    Wallet? wallet = ref.watch(viewPrivateWalletProvider);
    TextStyle? titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(color: Theme.of(context).primaryColor);
    return WillPopScope(
      onWillPop: () async {
        ref.read(viewPrivateWalletProvider.notifier).clear();
        return true;
      },
      child: Scaffold(
        body: wallet != null
            ? Padding(
                padding: const EdgeInsets.only(
                    top: 14, right: 18, left: 18, bottom: 0),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      toolbarHeight: 120,
                      bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(60),
                          child: Hero(
                            tag: "anon_logo",
                            child: SizedBox(
                                width: 160,
                                child: Image.asset("assets/anon_logo.png")),
                          )),
                    ),
                    SliverToBoxAdapter(
                      child: ListTile(
                        title: Text("PRIMARY ADDRESS", style: titleStyle),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SelectableText("${wallet.address}",
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Divider(
                        color: Colors.white54,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ListTile(
                        title: Text("MNEMONIC", style: titleStyle),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Wrap(
                              children: (wallet.seed).map((e) {
                                return Container(
                                  padding: const EdgeInsets.all(4),
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                      color: Colors.white10),
                                  child: Text("${e}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Divider(
                        color: Colors.white54,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ListTile(
                        title: Text("VIEW-KEY", style: titleStyle),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SelectableText(wallet.secretViewKey,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Divider(
                        color: Colors.white54,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ListTile(
                        title: Text("SPEND-KEY", style: titleStyle),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SelectableText(wallet.spendKey,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : SizedBox(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showPassphraseDialog();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showPassphraseDialog() {
    TextEditingController controller = TextEditingController();
    FocusNode focusNode = FocusNode();
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
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        ref.read(viewPrivateWalletProvider.notifier).clear();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(viewPrivateWalletProvider.notifier)
                              .getWallet(controller.text);
                          AppHaptics.lightImpact();
                          Navigator.pop(context);
                        } on PlatformException catch (e, s) {
                          debugPrintStack(stackTrace: s);
                          error.value = e.message;
                        } catch (e, s) {
                          // debugPrintStack(stackTrace: s);
                          error.value = "Error $e";
                        }
                      },
                      child: const Text("Confirm"))
                ],
              );
            },
          );
        });
  }
}
