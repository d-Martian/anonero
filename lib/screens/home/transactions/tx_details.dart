import 'package:anon_wallet/channel/wallet_channel.dart';
import 'package:anon_wallet/models/transaction.dart';
import 'package:anon_wallet/screens/home/transactions/tx_item_widget.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class TxDetails extends ConsumerStatefulWidget {
  final Transaction transaction;

  const TxDetails({Key? key, required this.transaction}) : super(key: key);

  @override
  ConsumerState<TxDetails> createState() => _TxDetailsState();
}

class _TxDetailsState extends ConsumerState<TxDetails> {
  String? txKey = "";
  bool loading = false;
  GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor);
    Transaction transaction = ref.watch(getSpecificTransaction(widget.transaction));
    Transfer? transfer = transaction.transfers.length == 1 ? transaction.transfers[0] : null;
    InlineSpan destination = const TextSpan(text: "");
    if (transfer == null) {
      if (transaction.subAddress != null) {
        destination = TextSpan(
          style: const TextStyle(
            height: 1.5
          ),
          text: "",
          children: <TextSpan>[
            TextSpan(
              text: "[${transaction.subAddress!.label}]",
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
            TextSpan(
              text: "  ${transaction.subAddress!.address}",
              style: const TextStyle(color: Colors.white70),
            )
          ],
        );
      }
    } else {
      destination = TextSpan(text: transfer.address ?? '-');
    }
    return Scaffold(
      key: scaffold,
      appBar: AppBar(
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Opacity(
              opacity: loading ? 1 : 0,
              child: const LinearProgressIndicator(
                minHeight: 1,
              ),
            )),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
                margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                child: TransactionItem(
                  transaction: transaction,
                )),
          ),
          SliverToBoxAdapter(
              child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: ListTile(
              title: Text(
                "DESTINATION",
                style: titleStyle,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: RichText(
                  text: destination,
                ),
              ),
            ),
          )),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: ListTile(
                onTap: () {
                  showPassphraseDialog(context,transaction);
                },
                trailing: Icon(Icons.edit),
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
            child: txKey == null ?  Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: ListTile(
                title: Text(
                  "TRANSACTION KEY",
                  style: titleStyle,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(txKey ?? '-'),
                ),
              ),
            ): SizedBox(),
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
                  child: Text("${transaction.blockheight == 0 ? 'Pending' : transaction.blockheight ?? '-'}"),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchTxKey();
    });
  }

  void showPassphraseDialog(BuildContext dialogContext, Transaction transaction) {
    TextEditingController controller = TextEditingController(text: transaction.notes ?? "");
    FocusNode focusNode = FocusNode();
    showDialog(
        context: dialogContext,
        barrierColor: barrierColor,
        barrierDismissible: false,
        builder: (_) {
          return HookBuilder(
            builder: (_) {
              const inputBorder = UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent));
              var error = useState<String?>(null);
              useEffect(() {
                focusNode.requestFocus();
                return null;
              }, []);
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Notes",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Padding(padding: EdgeInsets.all(12)),
                      TextField(
                          focusNode: focusNode,
                          controller: controller,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              errorText: error.value,
                              fillColor: Colors.grey[900],
                              filled: true,
                              focusedBorder: inputBorder,
                              border: inputBorder,
                              errorBorder: inputBorder)),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () async {
                        setTxUserNotes(controller.text, context);
                        Navigator.pop(context);
                      },
                      child: const Text("Confirm"))
                ],
              );
            },
          );
        });
  }

  String formatTimeAndDate(int? timestamp) {
    if (timestamp == null) {
      return "";
    }
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat("H:mm dd/MM/yyy").format(dateTime);
  }

  void fetchTxKey() async {
    if (widget.transaction.hash != null) {
      try {
        String? key = await WalletChannel().getTxKey(widget.transaction.hash!);
        if (key != null) {
          setState(() {
            txKey = key;
          });
        }
      } catch (e, s) {
        debugPrintStack(stackTrace: s);
      }
    }
  }

  void setTxUserNotes(String notes, BuildContext context) async {
    if (widget.transaction.hash != null) {
      try {
        setState(() {
          loading = true;
        });
        bool key = await WalletChannel().setTxUserNotes(widget.transaction.hash!, notes);
        setState(() {
          loading = false;
          widget.transaction.notes = notes;
        });
      } catch (e, s) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
          content: Text("Error ${e}"),
          leading: const Icon(Icons.info_outline),
          actions: [
            IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).clearMaterialBanners();
                },
                icon: const Icon(Icons.close))
          ],
        ));
        debugPrintStack(stackTrace: s);
      }
    }
  }
}
