import 'dart:ffi';
import 'dart:math';

import 'package:anon_wallet/channel/node_channel.dart';
import 'package:anon_wallet/models/transaction.dart';
import 'package:anon_wallet/state/node_state.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({Key? key}) : super(key: key);

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: false,
          floating: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          expandedHeight: 180,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.lock)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.crop_free)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
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
          title: const Text("ANON"),
        ),
        Consumer(builder: (context, ref, c) {
          bool isConnecting = ref.watch(connectingToNodeStateProvider);
          Map<String, num>? sync = ref.watch(syncProgressStateProvider);

          if (isConnecting) {
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
            if (sync != null) {
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
    );
  }

  List<num> _fakeData() {
    return List.generate(50, (index) => 1 + Random().nextInt(50 - 1) - (index * .2));
  }

  Widget _buildTxItem(Transaction transaction) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey.shade600),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (transaction.amount ?? 0) < 0
              ? Icon(
                  CupertinoIcons.arrow_turn_left_up,
                  color: Theme.of(context).primaryColor,
                )
              : const Icon(CupertinoIcons.arrow_turn_left_down),
          Text(
            formatMonero(transaction.amount),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Column(
            children: [Text(formatTime(transaction.timeStamp), style: Theme.of(context).textTheme.caption)],
          )
        ],
      ),
    );
  }
}

String formatTime(int? timestamp) {
  if (timestamp == null) {
    return "";
  }
  var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat("H:m\ndd/M").format(dateTime);
}
