import 'package:anon_wallet/channel/node_channel.dart';
import 'package:anon_wallet/models/node.dart';
import 'package:anon_wallet/screens/onboard/onboard_state.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NodesSettingsScreens extends ConsumerStatefulWidget {
  const NodesSettingsScreens({Key? key}) : super(key: key);

  @override
  ConsumerState<NodesSettingsScreens> createState() => _NodesSettingsScreensState();
}

class _NodesSettingsScreensState extends ConsumerState<NodesSettingsScreens> {
  List<Node> nodes = [];
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      load();
    });
  }

  load() async {
    setState(() {
      loading = true;
    });
    var values = await NodeChannel().getAllNodes();
    setState(() {
      nodes = values;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("Nodes"),
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  return TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            barrierColor: barrierColor,
                            builder: (context) {
                              return Container(
                                height: MediaQuery.of(context).size.height / 1.6,
                                child: Scaffold(
                                  body: RemoteNodeAddSheet(),
                                ),
                              );
                            }).then((value) => load());
                      },
                      child: const Text("Add Node"));
                },
              )
            ],
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            return Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          barrierColor: barrierColor,
                          builder: (context) {
                            return NodeDetails(nodes[index]);
                          }).then((value) => load());
                    },
                    child: Card(
                      color: Colors.grey[900]?.withOpacity(0.9),
                      child: ListTile(
                        title: Text("${nodes[index].host}", maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text("Height: ${nodes[index].height}"),
                        trailing: nodes[index].isActive == true
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 12,
                                    width: 12,
                                    decoration:
                                        BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                                  ),
                                  const Text("Active")
                                ],
                              )
                            : IconButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    barrierColor: barrierColor,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                        content: const Text("Do you want to remove this node ?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel")),
                                          TextButton(
                                              onPressed: () {
                                                NodeChannel().removeNode(nodes[index]).then((value) {
                                                  load();
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Delete")),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.delete)),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white54,
                )
              ],
            );
          }, childCount: nodes.length))
        ],
      ),
    );
  }
}

class NodeDetails extends StatefulWidget {
  final Node node;

  const NodeDetails(this.node, {Key? key}) : super(key: key);

  @override
  State<NodeDetails> createState() => _NodeDetailsState();
}

class _NodeDetailsState extends State<NodeDetails> {
  Node? node;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        node = widget.node;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      contentPadding: const EdgeInsets.only(
        top: 2,
        left: 12,
        right: 12,
        bottom: 6
      ),
      content: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 344,
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: loading ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: const LinearProgressIndicator(
                  minHeight: 1,
                ),
              ),
              AnimatedOpacity(
                opacity: error!=null ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  width: double.infinity,
                  color: Colors.red,
                  child: Text("$error",style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 13),
                  maxLines: 1),
                ),
              ),
              ListTile(
                title: Text("Host"),
                subtitle: Text("${node?.host}"),
              ),
              const Divider(color: Colors.white70),
              ListTile(
                title: const Text("Height"),
                trailing: Text("${node?.height}"),
              ),
              const Divider(color: Colors.white70),
              ListTile(
                title: const Text("Port"),
                trailing: Text("${widget.node.port}"),
              ),
              const Divider(color: Colors.white70),
              ListTile(
                title: const Text("Version"),
                trailing: Text("${node?.majorVersion}"),
              ),
              const Divider(color: Colors.white70),
            ],
          )),
      actions: [
        TextButton(
            onPressed: !loading ?  () {
              testRpc();
            }: null,
            child: const Text("Test Network")),
        TextButton(
            onPressed: !loading ? () {
              if (node != null) {
                setAsCurrentNode(node!);
              }
            } : null,
            child: const Text("Set Node")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"))
      ],
    );
  }

  void testRpc() async {
    Node widgetNode = widget.node;
    try {
      setState(() {
        loading = true;
        error = null;
      });
      Node? refreshedNode = await NodeChannel().testRpc(widgetNode.host, widgetNode.port ?? 80, widgetNode.username, widgetNode.password);
      if (refreshedNode != null) {
        setState(() {
          loading = false;
          node = refreshedNode;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = "${e}";
      });
      print(e);
    }
  }

  void setAsCurrentNode(Node node) async {
    try {
      setState(() {
        error = null;
        loading = true;
      });
      await NodeChannel().setCurrentNode(node);
      setState(() {
        loading = false;
        error = null;
      });
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        loading = false;
        error = "${e}";
      });
      print(e);
    }
  }
}

final nodeRemoteConnectionProvider = StateNotifierProvider<ConnectToNodeState, Node?>((ref) {
  return ConnectToNodeState(ref);
});

class RemoteNodeAddSheet extends HookConsumerWidget {
  const RemoteNodeAddSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController nodeTextController = useTextEditingController(text: "");
    TextEditingController userNameTextController = useTextEditingController(text: "");
    TextEditingController passWordTextController = useTextEditingController(text: "");
    var isLoading = useState(false);
    var nodeStatus = useState<String?>(null);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: Text("Add Node"),
          centerTitle: true,
          bottom: isLoading.value
              ? const PreferredSize(preferredSize: Size.fromHeight(1), child: LinearProgressIndicator(minHeight: 1))
              : null,
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text("NODE", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
            ),
            subtitle: TextField(
              controller: nodeTextController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
                helperText: nodeStatus.value,
                helperMaxLines: 3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'http://address.onion:port',
              ),
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
              controller: userNameTextController,
              textInputAction: TextInputAction.next,
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
              controller: passWordTextController,
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
                ElevatedButton(
                  onPressed: () {
                    connect(nodeTextController.text, userNameTextController.text, passWordTextController.text,
                        isLoading, nodeStatus, context);
                  },
                  style: Theme.of(context)
                      .elevatedButtonTheme
                      .style
                      ?.copyWith(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white)),
                  child: Text("Add Node"),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Future connect(String host, String username, String password, ValueNotifier<bool> isLoading,
      ValueNotifier<String?> nodeStatus, BuildContext context) async {
    int port = 38081;
    Uri uri = Uri.parse(host);
    if (uri.hasPort) {
      port = uri.port;
    }
    try {
      isLoading.value = true;
      Node? node = await NodeChannel().addNode(uri.host, port, username, password);
      if (node != null) {
        nodeStatus.value = "Connected to ${node.host}\nHeight : ${node.height}";
      }
      isLoading.value = false;
      await Future.delayed(const Duration(milliseconds: 600));
      Navigator.pop(context);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.message}")));
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }
}
