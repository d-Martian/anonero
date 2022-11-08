import 'package:anon_wallet/models/transaction.dart';
import 'package:anon_wallet/screens/home/transactions/transactions_list.dart';
import 'package:anon_wallet/screens/home/transactions/tx_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TxDetails extends StatefulWidget {
  final Transaction transaction;

  const TxDetails({Key? key, required this.transaction}) : super(key: key);

  @override
  State<TxDetails> createState() => _TxDetailsState();
}

class _TxDetailsState extends State<TxDetails> {
  @override
  Widget build(BuildContext context) {
    TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor);
    Transaction transaction = widget.transaction;
    Transfer? transfer = transaction.transfers.length == 1 ? transaction.transfers[0] : null;
    return Scaffold(
      appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: TransactionItem(
                  transaction: widget.transaction,
                )),
          ),
          SliverToBoxAdapter(
            child: transfer != null
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    child: ListTile(
                      title: Text(
                        "DESTINATION",
                        style: titleStyle,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(transfer.address ?? '-'),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: ListTile(
                title: Text(
                  "DESCRIPTION",
                  style: titleStyle,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(transaction.notes ?? '-'),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: ListTile(
                title: Text("TRANSACTION ID", style: titleStyle),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(transaction.hash ?? '-'),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: ListTile(
                title: Text(
                  "TRANSACTION KEY",
                  style: titleStyle,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(transaction.txKey ?? '-'),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: ListTile(
                title: Text(
                  "CONFIRMATION BLOCK",
                  style: titleStyle,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("${transaction.blockheight == 0 ? 'Pending': transaction.blockheight ?? '-'}"),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: ListTile(
                title: Text(
                  "TIMESTAMP",
                  style: titleStyle,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(formatTimeAndDate(transaction.timeStamp)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String formatTimeAndDate(int? timestamp) {
    if (timestamp == null) {
      return "";
    }
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat("H:mm dd/MM/yyy").format(dateTime);
  }
}
