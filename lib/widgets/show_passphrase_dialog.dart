import 'dart:async';

import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef ValidateCallBack<bool> = bool Function(String passPhrase);

Future<String?> showPassPhraseDialog(BuildContext context,
    {String title = "Enter Passphrase", ValidateCallBack? validate}) async {
  FocusNode focusNode = FocusNode();
  TextEditingController seedPassphraseController = TextEditingController();
  Completer completer = Completer<String?>();
  await showDialog(
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
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Padding(padding: EdgeInsets.all(12)),
                    TextField(
                        focusNode: focusNode,
                        controller: seedPassphraseController,
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
                      completer.complete(null);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (validate != null) {
                        if (!validate(seedPassphraseController.text)) {
                          error.value = "Invalid Passphrase";
                          return;
                        } else {
                          completer.complete(seedPassphraseController.text);
                        }
                      } else {
                        completer.complete(seedPassphraseController.text);
                      }
                    },
                    child: const Text("Confirm"))
              ],
            );
          },
        );
      });
  return await completer.future;
}
