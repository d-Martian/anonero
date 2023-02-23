
import 'package:anon_wallet/channel/wallet_backup_restore_channel.dart';
import 'package:anon_wallet/screens/onboard/restore/restore_node_setup.dart';
import 'package:anon_wallet/screens/set_pin_screen.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:anon_wallet/widgets/show_passphrase_dialog.dart';
import 'package:flutter/material.dart';

class RestoreFromSeed extends StatefulWidget {
  const RestoreFromSeed({Key? key}) : super(key: key);

  @override
  State<RestoreFromSeed> createState() => _RestoreFromSeedState();
}

class _RestoreFromSeedState extends State<RestoreFromSeed> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: [
        Expanded(
            child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text(""),
            ),
            SliverToBoxAdapter(
              child: Container(
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
            SliverFillRemaining(
              hasScrollBody: false,
              child: RestoreNodeSetup(
                  onButtonPressed: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease);
                  },
                  skipAppBar: true,
                  pageController: _pageController),
            )
          ],
        )),
        SeedEntry(
          onSeedEntered: (List<String> seed, int height) {
            onSeedEntered(seed, height, context);
          },
        ),
        Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 280,
                      height: 280,
                      child:  CircularProgressIndicator(strokeWidth: 2),
                    ),
                    Hero(
                        tag: "anon_logo",
                        child: SizedBox(
                            width: 180,
                            child: Image.asset("assets/anon_logo.png"))),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text("Restoring wallet..."),
                )
              ],
            ),
          ),
        )
      ],
    ));
  }

  onSeedEntered(List<String> seed, int height, BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final navigator = Navigator.of(context);
    String? passPhrase = await showPassPhraseDialog(context,title: "Enter seed passphrase",);
    if (passPhrase != null) {
      String pin = await navigator.push(
          MaterialPageRoute(
            builder: (context) => const SetPinScreen(
              title: "Set up pin",
            ),
          ));
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease);
      await Future.delayed(const Duration(milliseconds: 600));
      BackUpRestoreChannel()
          .restoreFromSeed(seed.join(" "), height, passPhrase, pin);
    }
  }
}

class SeedEntry extends StatefulWidget {
  final Function(List<String> seed, int height) onSeedEntered;

  const SeedEntry({Key? key, required this.onSeedEntered}) : super(key: key);

  @override
  State<SeedEntry> createState() => _SeedEntryState();
}

class _SeedEntryState extends State<SeedEntry> {
  List<String> seed = [];
  String? seedPassphrase;
  int restoreHeight = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Hero(
                    tag: "anon_logo",
                    child: SizedBox(
                        width: 180,
                        child: Image.asset("assets/anon_logo.png"))),
                Text(
                  "MNEMONIC SEED",
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontSize: 22),
                )
              ],
            ),
          ),
          const SliverPadding(padding: EdgeInsets.all(24)),
          SliverToBoxAdapter(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("ENTER SEED",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary)),
              ),
              subtitle: TextField(
                onChanged: (value) {
                  setState(() {
                    seed = value.split(" ");
                  });
                },
                maxLines: 6,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Enter your seed with spaces',
                ),
              ),
            ),
          ),
          SliverOpacity(
            opacity: seed.length >= 17 ? 1 : 0,
            sliver: SliverToBoxAdapter(
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text("RESTORE HEIGHT",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary)),
                ),
                subtitle: TextField(
                  onChanged: (value) {
                    try {
                      restoreHeight = int.parse(value);
                    } catch (e) {}
                  },
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: '',
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Opacity(
                  opacity: seed.length >= 25 ? 1 : 0,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(width: 1.0, color: Colors.white),
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 12, color: Colors.white),
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 6)),
                      onPressed: () async {
                        widget.onSeedEntered(seed, restoreHeight);
                      },
                      child: const Text("Next"),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
