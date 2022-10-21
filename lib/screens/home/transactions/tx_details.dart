import 'package:anon_wallet/models/transaction.dart';
import 'package:flutter/material.dart';

class TxDetails extends StatefulWidget {
  final Transaction transaction;
  const TxDetails({Key? key,required this.transaction}) : super(key: key);

  @override
  State<TxDetails> createState() => _TxDetailsState();
}

class _TxDetailsState extends State<TxDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
    );
  }
}
