import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';

class WalletPassphraseWidget extends StatelessWidget {
  final Function(String value) onPassSeedPhraseAdded;

  WalletPassphraseWidget({Key? key, required this.onPassSeedPhraseAdded}) : super(key: key);
  final TextEditingController passPhraseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 120,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(tag: "anon_logo", child: SizedBox(width: 180, child: Image.asset("assets/anon_logo.png"))),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("Enter passphrase", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: TextField(
                controller: passPhraseController,
                enableIMEPersonalizedLearning: false,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("Confirm passphrase", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: TextField(
                enableIMEPersonalizedLearning: false,
                enableSuggestions: false,
                autocorrect: false,
                onChanged: (String value) {
                  if (passPhraseController.text == value) {
                    onPassSeedPhraseAdded(value);
                  }else{
                    onPassSeedPhraseAdded("");
                  }
                },
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '',
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
                    "Enter your seed passphrase\n",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text("NOTE: Passphrase is required\nto restore from\nseed or backup file",
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall)
                ],
              ),
            ),
          )
        ],
      ),
    );
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(tag: "anon_logo", child: SizedBox(width: 180, child: Image.asset("assets/anon_logo.png"))),
            ],
          )),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("Enter passphrase", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: TextField(
                controller: passPhraseController,
                enableIMEPersonalizedLearning: false,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '',
                ),
              ),
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("Confirm passphrase", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: TextField(
                enableIMEPersonalizedLearning: false,
                enableSuggestions: false,
                autocorrect: false,
                onChanged: (String value) {
                  if (passPhraseController.text == value) {
                    onPassSeedPhraseAdded(value);
                  }
                },
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '',
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Enter your seed passphrase\n",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text("NOTE: Passphrase is required\nto restore from\nseed or backup file",
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
