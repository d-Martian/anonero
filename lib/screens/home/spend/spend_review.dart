import 'package:anon_wallet/models/broadcast_tx_state.dart';
import 'package:anon_wallet/screens/home/spend/spend_state.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SpendReview extends ConsumerWidget {
  final VoidCallback onConfirm;
  final VoidCallback close;

  const SpendReview({Key? key, required this.onConfirm, required this.close}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle? titleTheme = Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor);
    String address = ref.watch(addressStateProvider);
    String notes = ref.watch(notesStateProvider);
    TxState txState = ref.watch(transactionStateProvider);
    var fees = txState.fee;
    var amount = txState.amount;
    bool loading = txState.isLoading();
    bool hasError = txState.hasError();

    if (hasError) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: 120,
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Hero(
                    tag: "anon_logo",
                    child: SizedBox(width: 160, child: Image.asset("assets/anon_logo.png")),
                  )),
            ),
            SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListTile(
                    title: Text("Address", style: titleTheme),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        address,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )),
            ),
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text(
                  "Error ${txState.errorString}",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.center,
                  child: TextButton(
                    child: const Text("Close"),
                    onPressed: () {
                      close();
                    },
                  )),
            )
          ],
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            toolbarHeight: 120,
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Hero(
                  tag: "anon_logo",
                  child: SizedBox(width: 160, child: Image.asset("assets/anon_logo.png")),
                )),
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  title: Text("Address", style: titleTheme),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )),
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  title: Text("Description", style: titleTheme),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      notes.isNotEmpty ? notes : "N/A",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SpendListItem(
                title: "Amount",
                isLoading: loading,
                subTitle: "${formatMonero(amount)} XMR",
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SpendListItem(
                title: "Fee",
                isLoading: loading,
                subTitle: "${formatMonero((fees ?? 0), minimumFractions: 8)} XMR",
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SpendListItem(
                title: "Total",
                isLoading: loading,
                subTitle: "${formatMonero((fees ?? 0) + (amount ?? 0), minimumFractions: 8)} XMR",
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: ElevatedButton(
                    onPressed: !loading
                        ? () {
                            onConfirm();
                          }
                        : null,
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                        backgroundColor:
                            MaterialStateColor.resolveWith((states) => loading ? Colors.white54 : Colors.white)),
                    child: Text("CONFIRM",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black, fontWeight: FontWeight.w800)),
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

class SpendListItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool isLoading;

  const SpendListItem({Key? key, required this.title, this.isLoading = false, required this.subTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor)),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: isLoading
            ? Container(
                width: 12,
                height: 12,
                child: const CircularProgressIndicator(strokeWidth: 1),
              )
            : Text(
                subTitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
              ),
      ),
    );
  }
}
