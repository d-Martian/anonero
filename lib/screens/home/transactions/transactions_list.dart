import 'dart:ffi';
import 'dart:math';

import 'package:anon_wallet/anon_wallet.dart';
import 'package:anon_wallet/channel/node_channel.dart';
import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/models/transaction.dart';
import 'package:anon_wallet/state/node_state.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionsList extends StatefulWidget {

  final VoidCallback? onScanClick ;
  const TransactionsList({Key? key,this.onScanClick}) : super(key: key);

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await WalletChannel().refresh();
        return;
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            centerTitle: false,
            floating: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 180,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.lock)),
              IconButton(onPressed: () {
                widget.onScanClick?.call();
              }, icon: const Icon(Icons.crop_free)),
              PopupMenuButton<int>(
                color: Colors.grey[900],
                onSelected: (item)  {
                  if(item == 0 ){
                    WalletChannel().rescan();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(value: 0, child: Text('Resync blockchain')),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.pin,
              background: Container(
                margin: const EdgeInsets.only(top: 80),
                alignment: Alignment.center,
                child: Consumer(
                  builder: (context, ref, c) {
                    var amount = ref.watch(walletBalanceProvider);
                    return Text(
                      "${formatMonero(amount)} XMR",
                      style: Theme.of(context).textTheme.headline4,
                    );
                  },
                ),
              ),
            ),
            title: const Text("[ΛИ0И]"),
          ),
          Consumer(builder: (context, ref, c) {
            bool isConnecting = ref.watch(connectingToNodeStateProvider);
            bool isWalletOpening = ref.watch(walletLoadingProvider) ?? false;
            bool connected = ref.watch(connectionStatus) ?? false;
            Map<String, num>? sync = ref.watch(syncProgressStateProvider);
            if (isConnecting || isWalletOpening) {
              return SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  toolbarHeight: 8,
                  collapsedHeight: 8,
                  floating: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  flexibleSpace: const LinearProgressIndicator(
                    minHeight: 1,
                  ));
            } else {
              if (!connected){
                return SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: true,
                    toolbarHeight: 10,
                    collapsedHeight: 10,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: Column(
                      children: [
                        const LinearProgressIndicator(),
                        const Padding(padding: EdgeInsets.all(6)),
                        Text(
                          "Disconnected",
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ));
              }else if (sync != null ) {
                return SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: true,
                    toolbarHeight: 10,
                    collapsedHeight: 10,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: Column(
                      children: [
                        LinearProgressIndicator(
                          value: sync['progress']?.toDouble() ?? 0.0,
                        ),
                        const Padding(padding: EdgeInsets.all(6)),
                        Text(
                          "Syncing blocks : ${sync['remaining']} blocks remaining",
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ));
              }
              return const SliverToBoxAdapter();
            }
          }),
          Consumer(
            builder: (context, ref, child) {
              List<Transaction> transactions = ref.watch(walletTransactions);
              return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return _buildTxItem(transactions[index]);
              }, childCount: transactions.length));
            },
          )
        ],
      ),
    );
  }

  Widget _buildTxItem(Transaction transaction) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: transaction.isSpend ? Theme.of(context).primaryColor : Colors.grey.shade600),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getStats(transaction),
            Text(
              formatMonero(transaction.amount),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Column(
              children: [Text(formatTime(transaction.timeStamp), style: Theme.of(context).textTheme.caption)],
            )
          ],
        ),
      ),
    );
  }

  getStats(Transaction transaction) {
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green, fontSize: 12),
            )
          ],
        ),
      );
    }
    return (transaction.isSpend)
        ? Icon(
            CupertinoIcons.arrow_turn_left_up,
            color: Theme.of(context).primaryColor,
          )
        : const Icon(CupertinoIcons.arrow_turn_left_down);
  }
}

String formatTime(int? timestamp) {
  if (timestamp == null) {
    return "";
  }
  var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat("HH:mm\ndd/M").format(dateTime);
}
