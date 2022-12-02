import 'package:anon_wallet/models/sub_address.dart';
import 'package:anon_wallet/screens/home/subaddress/edit_sub_address.dart';
import 'package:anon_wallet/screens/home/transactions/tx_details.dart';
import 'package:anon_wallet/screens/home/transactions/tx_item_widget.dart';
import 'package:anon_wallet/state/sub_addresses.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../models/transaction.dart';

class SubAddressDetails extends ConsumerStatefulWidget {
  final SubAddress subAddress;

  const SubAddressDetails({Key? key, required this.subAddress})
      : super(key: key);

  @override
  ConsumerState<SubAddressDetails> createState() => _SubAddressDetailsState();
}

class _SubAddressDetailsState extends ConsumerState<SubAddressDetails> {
  @override
  Widget build(BuildContext context) {
    SubAddress subAddress = ref.watch(getSpecificSubAddress(widget.subAddress));
    List<Transaction> transactions = ref.watch(subAddressDetails(subAddress));
    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(builder: (context) {
            return IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: subAddress.address));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("address copied",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white)),
                    backgroundColor: Colors.grey[900],
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                icon: Icon(Icons.copy));
          }),
          IconButton(
              onPressed: () {
                showDialog(
                    barrierColor: barrierColor,
                    context: context,
                    builder: (context) {
                      return SubAddressEditDialog(subAddress);
                    });
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
              child: ListTile(
                title: Text(
                  subAddress.label ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).primaryColor),
                ),
                subtitle: Text(subAddress.address ?? ''),
                trailing: Text(
                  formatMonero(subAddress.totalAmount),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TxDetails(transaction: transactions[index]),
                          fullscreenDialog: true));
                },
                child: TransactionItem(
                  transaction: transactions[index],
                ),
              ),
            );
          }, childCount: transactions.length)),
          SliverToBoxAdapter(
            child: transactions.isEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: Text("No transactions yet..",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70)),
                    ),
                  )
                : SizedBox(),
          )
        ],
      ),
    );
  }
}
