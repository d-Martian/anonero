import 'package:anon_wallet/anon_wallet.dart';
import 'package:anon_wallet/models/transaction.dart';
import 'package:anon_wallet/screens/home/transactions/transactions_list.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "tx:${transaction.hash}",
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(
                width: 1,
                color: transaction.isSpend
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getStats(transaction, context),
            Text(
              formatMonero(transaction.amount),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Column(
              children: [
                Text(formatTime(transaction.timeStamp),
                    style: Theme.of(context).textTheme.caption)
              ],
            )
          ],
        ),
      ),
    );
  }

  getStats(Transaction transaction, BuildContext context) {
    if (!(transaction.isConfirmed ?? false)) {
      int confirms = transaction.confirmations ?? 0;
      double progress = confirms / maxConfirms;
      return SizedBox(
        height: 30,
        width: 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.green,
              strokeWidth: 1,
              value: progress,
            ),
            Text(
              "$confirms",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.green, fontSize: 12),
            )
          ],
        ),
      );
    } else {
      return (transaction.isSpend)
          ? Icon(
              CupertinoIcons.arrow_turn_left_up,
              color: Theme.of(context).primaryColor,
            )
          : const Icon(CupertinoIcons.arrow_turn_left_down);
    }
  }
}
