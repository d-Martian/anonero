import 'package:anon_wallet/channel/address_channel.dart';
import 'package:anon_wallet/models/sub_address.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_haptics.dart';

class SubAddressEditDialog extends StatefulWidget {
  final SubAddress subAddress;

  const SubAddressEditDialog(this.subAddress, {Key? key}) : super(key: key);

  @override
  State<SubAddressEditDialog> createState() => _SubAddressEditDialogState();
}

class _SubAddressEditDialogState extends State<SubAddressEditDialog> {
  FocusNode focusNode = FocusNode();
  TextEditingController labelEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      labelEditingController.text = widget.subAddress.getLabel();
      focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(left: 12, right: 12, top: 18),
      titlePadding: const EdgeInsets.only(top: 24, left: 12),
      actionsPadding: const EdgeInsets.only(top: 4, left: 12, bottom: 12),
      title: Text(
        "Rename subaddress",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 1,
        child: TextFormField(
          controller: labelEditingController,
          focusNode: focusNode,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              fillColor: Color(0xff1E1E1E),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)))),
          style: const TextStyle(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            )),
        TextButton(
            onPressed: () {
              if (widget.subAddress.addressIndex != null) {
                AddressChannel().setSubAddressLabel(
                    widget.subAddress.addressIndex!,
                    widget.subAddress.accountIndex!,
                    labelEditingController.text);
                AppHaptics.lightImpact();
                Navigator.pop(context);
              }
            },
            child: Text("Confirm",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800)))
      ],
    );
  }
}
