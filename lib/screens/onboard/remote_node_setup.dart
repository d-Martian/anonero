import 'package:anon_wallet/models/node.dart';
import 'package:anon_wallet/screens/onboard/onboard_state.dart';
import 'package:anon_wallet/state/node_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RemoteNodeWidget extends ConsumerWidget {
  const RemoteNodeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    Node? node = ref.watch(nodeConnectionProvider);
    String? nodeMessage;
    if (node != null && node.responseCode <= 200) {
      nodeMessage = "Connected to ${node.host}\nHeight : ${node.height}";
    }
    return SafeArea(
  	child: Container( 
      height: MediaQuery.of(context).size.height - 120,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
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
                child: Text("NODE", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
              ),
              subtitle: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      ref.read(remoteHost.state).state = value;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
              		borderRadius: BorderRadius.circular(12),
              		borderSide: BorderSide(color: Colors.white, width: 1),
              	),
                      helperText: nodeMessage,
                      helperMaxLines: 3,
                      border: OutlineInputBorder(
                      	      borderRadius: BorderRadius.circular(12),                      
                      ),
                      hintText: 'http://address.onion:port',
                    ),
                  ),
                  Consumer(builder: (context, ref, c) {
                    bool isConnecting = ref.watch(connectingToNodeStateProvider);
                    if(isConnecting){
                      return const LinearProgressIndicator(minHeight: 1);
                    }else{
                      return const SizedBox();
                    }
                  })
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("USERNAME", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
              ),
              subtitle: TextField(
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  ref.read(remoteUserName.state).state = value;
                },
                decoration: InputDecoration(
              	enabledBorder: OutlineInputBorder(
              		borderRadius: BorderRadius.circular(12),
              		borderSide: BorderSide(color: Colors.white, width: 1),
              	),
                border: OutlineInputBorder(
                	borderRadius: BorderRadius.circular(12),
              	),
                  hintText: '(optional)',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("PASSWORD", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
              ),
              subtitle: TextField(
                onChanged: (value) {
                  ref.read(remotePassword.state).state = value;
                },
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
              	enabledBorder: OutlineInputBorder(
              		borderRadius: BorderRadius.circular(12),
              		borderSide: BorderSide(color: Colors.white, width: 1),
              	),
                border: OutlineInputBorder(
                	borderRadius: BorderRadius.circular(12),
              	),
                  hintText: '(optional)',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "ΛNON will only connect\nto the node specified above\n",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      ),
    );
  }
}

