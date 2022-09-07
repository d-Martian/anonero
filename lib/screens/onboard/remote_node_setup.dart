import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';

class RemoteNodeWidget extends StatelessWidget {
  const RemoteNodeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return      Container(
      height: MediaQuery.of(context).size.height - 120,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(tag: "anon_logo", child: SizedBox(width: 180, child: Image.asset("assets/anon_logo.png"))),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("Node", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: const TextField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'http://address.onion:port',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:   ListTile(
              title: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Username", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: TextField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '(optional)',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:  ListTile(
              title: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Password", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: TextField(
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '(optional)',
                ),
              ),
            ),
          ),SliverToBoxAdapter(
            child:Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "ΛNON will only connect to the node specified above\n",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text("If left blank, ΛNØN will connect\nto random community nodes",
                      style: Theme.of(context).textTheme.labelLarge)
                ],
              ),
            ) ,
          )
        ],
      ),
    );
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(tag: "anon_logo", child: SizedBox(width: 180, child: Image.asset("assets/anon_logo.png"))),
            ],
          )),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("Node", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: const TextField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'http://address.onion:port',
                ),
              ),
            ),
            ListTile(
              title: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Username", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: TextField(
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '(optional)',
                ),
              ),
            ),
            ListTile(
              title: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Password", style: TextStyle(color: colorScheme.primary)),
              ),
              subtitle: TextField(
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '(optional)',
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "ΛNON will only connect to the node specified above\n",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text("If left blank, ΛNØN will connect\nto random community nodes",
                      style: Theme.of(context).textTheme.labelLarge)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
