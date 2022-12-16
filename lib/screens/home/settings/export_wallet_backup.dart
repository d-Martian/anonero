import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/screens/home/settings/settings_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:anon_wallet/utils/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ExportWalletBackUpScreen extends ConsumerStatefulWidget {
  const ExportWalletBackUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExportWalletBackUpScreen> createState() =>
      _ExportWalletBackUpScreenState();
}

class _ExportWalletBackUpScreenState
    extends ConsumerState<ExportWalletBackUpScreen> {
  String? backup;

  @override
  Widget build(BuildContext context) {
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
        body:   CustomScrollView(
                slivers: [
                  SliverAppBar(
                    toolbarHeight: 120,
                    bottom: PreferredSize(
                        preferredSize: Size.fromHeight(60),
                        child: Hero(
                          tag: "anon_logo",
                          child: SizedBox(
                              width: 160,
                              child: Image.asset("assets/anon_logo.png")),
                        )),
                  ),
                  backup != null ?  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      child: Card(
                        color: Colors.white10,
                        elevation: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: SelectableText(
                            backup!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ) : const SliverToBoxAdapter(),
                  backup != null ?
                  SliverToBoxAdapter(
                      child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                    child: ButtonBar(
                      children: [
                        TextButton(
                          child: const Text('Export To File'),
                          onPressed: () {
                            WalletChannel().shareBackUpAsFile(backup!);
                          },
                        ),
                        Builder(builder: (context) {
                          return TextButton(
                            child: const Text('Copy'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: backup));
                              AppHaptics.lightImpact();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text("Copied",
                                    style: TextStyle(color: Colors.white)),
                                backgroundColor: Colors.grey[900],
                              ));
                            },
                          );
                        }),
                      ],
                    ),
                  )) : const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ],
              )

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

  void backUp(String password) async {
    String? value = await WalletChannel().getBackUp(password);
    setState(() {
      backup = value;
    });
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
                      loading.value ?
                           const LinearProgressIndicator(
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
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () async {
                        try {
                          loading.value = true;
                          backUp(controller.text);
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
