import 'package:anon_wallet/screens/home/spend/spend_state.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:anon_wallet/utils/app_haptics.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:anon_wallet/utils/parsers.dart';
import 'package:anon_wallet/widgets/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SpendForm extends ConsumerStatefulWidget {
  final VoidCallback onValidationComplete;

  const SpendForm({Key? key, required this.onValidationComplete})
      : super(key: key);

  @override
  ConsumerState<SpendForm> createState() => _SpendFormState();
}

class _SpendFormState extends ConsumerState<SpendForm> {
  TextEditingController addressEditingController = TextEditingController();
  TextEditingController amountEditingController = TextEditingController();
  TextEditingController noteEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addressEditingController.text = ref.read(addressStateProvider);
      amountEditingController.text = ref.read(amountStateProvider);
      noteEditingController.text = ref.read(notesStateProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(notesStateProvider, (previous, next) {
      if (noteEditingController.text != next) {
        noteEditingController.text = next;
      }
    });
    ref.listen<String>(addressStateProvider, (previous, next) {
      if (addressEditingController.text != next) {
        addressEditingController.text = next;
      }
    });
    ref.listen<String>(amountStateProvider, (previous, next) {
      if (amountEditingController.text != next) {
        amountEditingController.text = next;
      }
    });
    OutlineInputBorder enabledBorder = OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(12));

    OutlineInputBorder unFocusedBorder = OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: Colors.white),
        borderRadius: BorderRadius.circular(12));
    SpendValidationNotifier validationNotifier = ref.watch(validationProvider);

    bool? addressValid = validationNotifier.validAddress;
    bool? validAmount = validationNotifier.validAmount;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            toolbarHeight: 120,
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Hero(
                  tag: "anon_logo",
                  child: SizedBox(
                      width: 160, child: Image.asset("assets/anon_logo.png")),
                )),
          ),
          SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 34, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ADDRESS",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).primaryColor)),
                              const Padding(padding: EdgeInsets.all(12)),
                              TextFormField(
                                textAlign: TextAlign.start,
                                controller: addressEditingController,
                                keyboardType: TextInputType.text,
                                maxLines: 3,
                                minLines: 1,
                                onChanged: (value) {
                                  ref.read(addressStateProvider.state).state =
                                      value;
                                },
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  errorText: addressValid == false
                                      ? "Invalid address"
                                      : null,
                                  border: unFocusedBorder,
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        showBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return QRScannerView(
                                                onScanCallback: (value) {
                                                  AppHaptics.lightImpact();
                                                  var parsedAddress =
                                                      Parser.parseAddress(
                                                          value);
                                                  if (parsedAddress[0] !=
                                                      null) {
                                                    ref
                                                        .read(
                                                            addressStateProvider
                                                                .state)
                                                        .state = parsedAddress[0];
                                                  }
                                                  if (parsedAddress[1] !=
                                                      null) {
                                                    ref
                                                        .read(
                                                            amountStateProvider
                                                                .state)
                                                        .state = parsedAddress[1];
                                                  }
                                                  if (parsedAddress[2] !=
                                                      null) {
                                                    ref
                                                        .read(notesStateProvider
                                                            .state)
                                                        .state = parsedAddress[2];
                                                  }
                                                },
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.qr_code)),
                                  enabledBorder: unFocusedBorder,
                                  focusedBorder: enabledBorder,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 8),
                                  fillColor: const Color(0xff1E1E1E),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 34, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("AMOUNT",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).primaryColor)),
                              const Padding(padding: EdgeInsets.all(12)),
                              TextFormField(
                                controller: amountEditingController,
                                textAlign: TextAlign.center,
                                onChanged: (value) {
                                  ref.read(amountStateProvider.state).state =
                                      value;
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  hintText: "0.0000",
                                  errorText: validAmount == false
                                      ? "Invalid Amount"
                                      : null,
                                  suffixText: "XMR",
                                  border: unFocusedBorder,
                                  enabledBorder: unFocusedBorder,
                                  focusedBorder: enabledBorder,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 8),
                                  fillColor: const Color(0xff1E1E1E),
                                ),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 34, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("NOTES",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).primaryColor)),
                              const Padding(padding: EdgeInsets.all(12)),
                              TextFormField(
                                controller: noteEditingController,
                                textAlign: TextAlign.start,
                                onChanged: (value) {
                                  ref.read(notesStateProvider.state).state =
                                      value;
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  border: unFocusedBorder,
                                  enabledBorder: unFocusedBorder,
                                  focusedBorder: enabledBorder,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 8),
                                  fillColor: const Color(0xff1E1E1E),
                                ),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 80,
                      child: Consumer(
                        builder: (context, ref, c) {
                          num mainBalance = ref.watch(walletBalanceProvider);
                          num amount =
                              ref.watch(walletAvailableBalanceProvider);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Available Balance  : ${formatMonero(amount, minimumFractions: 8)} XMR",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Padding(padding: EdgeInsets.all(4)),
                              Text(
                                "UnConfirmed Balance: ${formatMonero(mainBalance, minimumFractions: 8)} XMR",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 24),
                      child: ElevatedButton(
                          onPressed: () {
                            validate(context);
                          },
                          style: ElevatedButtonTheme.of(context)
                              .style
                              ?.copyWith(
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => Colors.white)),
                          child: const Text("Next")),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  validate(BuildContext context) async {
    SpendValidationNotifier validationNotifier = ref.read(validationProvider);
    bool valid = await validationNotifier.validate(
        amountEditingController.text, addressEditingController.text);
    if (valid) {
      widget.onValidationComplete();
    }
  }
}
