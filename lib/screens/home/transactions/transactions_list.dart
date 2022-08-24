import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          expandedHeight: 200,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.lock)),
            IconButton(onPressed: () {}, icon: Icon(Icons.crop_free)),
            IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
          ],
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            collapseMode: CollapseMode.pin,
            background: Container(
              margin: EdgeInsets.only(top: 80),
              alignment: Alignment.center,
              child: Text(
                "451.01984 XMR",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
          title: Text("ANON"),
        ),
        SliverList(delegate: SliverChildListDelegate(_fakeData().map((e) => _buildTxItem(e)).toList()))
      ],
    );
  }

  List<num> _fakeData() {
    return List.generate(50, (index) => 1 + Random().nextInt(50 - 1) - (index * .2) );
  }

  Widget _buildTxItem(num index) {
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
         index > 1 ?  Icon(CupertinoIcons.arrow_turn_left_up,color:Theme.of(context).primaryColor ,) :  const Icon(CupertinoIcons.arrow_turn_left_down)  ,
          Text(
            "13.12054",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Column(
            children: [Text("19:08\n18/07", style: Theme.of(context).textTheme.caption)],
          )
        ],
      ),
    );
  }
}
