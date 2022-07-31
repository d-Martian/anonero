import 'package:flutter/material.dart';

class RemoteNodeWidget extends StatelessWidget {
  const RemoteNodeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const ListTile(
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("Node"),
            ),
            subtitle: TextField(
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'http://address.onion:port',
              ),
            ),
          ),
          const ListTile(
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("Username"),
            ),
            subtitle: TextField(
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '(optional)',
              ),
            ),
          ),
          const ListTile(
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("Password"),
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
    );
  }
}
