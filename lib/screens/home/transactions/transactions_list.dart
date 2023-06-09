import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/models/transaction.dart';
import 'package:anon_wallet/screens/home/transactions/sticky_progress.dart';
import 'package:anon_wallet/screens/home/transactions/tx_details.dart';
import 'package:anon_wallet/screens/home/transactions/tx_item_widget.dart';
import 'package:anon_wallet/screens/home/wallet_lock.dart';
import 'package:anon_wallet/state/node_state.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionsList extends StatefulWidget {
  final VoidCallback? onScanClick;

  const TransactionsList({Key? key, this.onScanClick}) : super(key: key);

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
            floating: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 180,
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  bool isConnecting = ref.watch(connectingToNodeStateProvider);
                  bool isWalletOpening =
                      ref.watch(walletLoadingProvider) ?? false;
                  bool isLoading = isConnecting || isWalletOpening;
                  return Opacity(
                    opacity: isLoading ? 0.5 : 1,
                    child: IconButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (isLoading) return;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletLock()));
                              },
                        icon: const Hero(
                          tag: "lock",
                          child: Icon(Icons.lock),
                        )),
                  );
                },
              ),
              IconButton(
                  onPressed: () {
                    widget.onScanClick?.call();
                  },
                  icon: const Icon(Icons.crop_free)),
              PopupMenuButton<int>(
                color: Colors.grey[900],
                onSelected: (item) {
                  if (item == 0) {
                    WalletChannel().rescan();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(
                      value: 0, child: Text('Resync blockchain')),
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
          const SyncProgressSliver(),
          Consumer(
            builder: (context, ref, child) {
              List<Transaction> transactions = ref.watch(walletTransactions);
              return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return _buildTxItem(transactions[index]);
              }, childCount: transactions.length));
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              List<Transaction> transactions = ref.watch(walletTransactions);
              bool isConnecting = ref.watch(connectingToNodeStateProvider);
              bool isWalletOpening = ref.watch(walletLoadingProvider) ?? false;
              Map<String, num>? sync = ref.watch(syncProgressStateProvider);
              bool isActive = isConnecting || isWalletOpening || sync != null;
              return  SliverPadding(padding: EdgeInsets.all(isActive ? 24 : 0));
            },
          )
        ],
      ),
    );
  }

  Widget _buildTxItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      child: Consumer(
        builder: (context, ref, c) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TxDetails(transaction: transaction),
                      fullscreenDialog: true));
            },
            child: TransactionItem(transaction: transaction),
          );
        },
      ),
    );
  }
}

String formatTime(int? timestamp) {
  if (timestamp == null) {
    return "";
  }
  var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat("H:mm\ndd/M").format(dateTime);
}
