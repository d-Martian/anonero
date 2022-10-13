import 'package:animations/animations.dart';
import 'package:anon_wallet/screens/home/spend/spend_form.dart';
import 'package:anon_wallet/screens/home/spend/spend_progress_widget.dart';
import 'package:anon_wallet/screens/home/spend/spend_review.dart';
import 'package:anon_wallet/screens/home/spend/spend_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SpendScreen extends ConsumerStatefulWidget {
  const SpendScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SpendScreen> createState() => _SpendScreenState();
}

class _SpendScreenState extends ConsumerState<SpendScreen> {
  var page = 1;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (page != 1) {
          setState(() {
            page = 1;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
          body: PageTransitionSwitcher(
        reverse: page == 1,
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return SharedAxisTransition(
            animation: animation,
            fillColor: Colors.transparent,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          );
        },
        duration: const Duration(milliseconds: 400),
        child: page == 1
            ? SpendForm(
                key: const ValueKey("SpendForm"),
                onValidationComplete: () {
                  createTransaction(ref, context);
                  setState(() {
                    page = 2;
                  });
                },
              )
            : page == 2
                ? SpendReview(
                    onConfirm: () => onConfirmTx(context, ref),
                    close: () {
                      setState(() {
                        page = 1;
                      });
                    },
                  )
                : SpendProgressWidget(
                    onCloseCallBack: () {
                      setState(() {
                        page = 1;
                      });
                    },
                  ),
      )),
    );
  }

  onConfirmTx(BuildContext context, WidgetRef ref)  async {
    setState(() {
      page = 3;
    });
    String amountStr = ref.read(amountStateProvider);
    String address = ref.read(addressStateProvider);
    String notes = ref.read(notesStateProvider);
    await ref.read(transactionStateProvider.notifier).broadcast(amountStr, address, notes);
    ref.read(amountStateProvider.state).state = "";
    ref.read(addressStateProvider.state).state = "";
    ref.read(notesStateProvider.state).state = "";
  }

  void createTransaction(WidgetRef ref, BuildContext context) {
    String amountStr = ref.read(amountStateProvider);
    String address = ref.read(addressStateProvider);
    String notes = ref.read(notesStateProvider);
    ref.read(transactionStateProvider.notifier).createPreview(amountStr, address, notes);
  }
}
