import 'package:flutter/material.dart';

class WalletPassphraseWidget extends StatelessWidget {
  const WalletPassphraseWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const ListTile(
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("Enter passphrase"),
            ),
            subtitle: TextField(
              enableIMEPersonalizedLearning: false,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '',
              ),
            ),
          ),
          const ListTile(
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("Confirm passphrase"),
            ),
            subtitle: TextField(
              enableIMEPersonalizedLearning: false,
              enableSuggestions: false,
              autocorrect: false,
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
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall)
              ],
            ),
          )
        ],
      ),
    );
  }
}
