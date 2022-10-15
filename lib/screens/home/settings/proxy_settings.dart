import 'package:anon_wallet/screens/home/settings/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProxySettings extends HookConsumerWidget {
  const ProxySettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    var proxyTextEditingController = useTextEditingController(text: "127.0.0.1");
    var portTextEditingController = useTextEditingController(text: "9050");

    useEffect(() {
      ref.read(proxyStateProvider.notifier).getState().then((value) {
        Proxy proxy = ref.read(proxyStateProvider);
        if (proxy.serverUrl.isNotEmpty) proxyTextEditingController.text = proxy.serverUrl;
        if (proxy.port.isNotEmpty) portTextEditingController.text = proxy.port;
      });
     return (){
       proxyTextEditingController.text = "";
       portTextEditingController.text = "";
     };
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Proxy Settings"),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                ListTile(
                  title: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Server"),
                  ),
                  subtitle: TextField(
                      controller: proxyTextEditingController,
                      onChanged: (value) {},
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white54, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                          ))),
                ),
                const Padding(padding: EdgeInsets.all(2)),
                ListTile(
                  title: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Port"),
                  ),
                  subtitle: TextField(
                      onChanged: (value) {},
                      controller: portTextEditingController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white54, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                          ))),
                ),
                const Padding(padding: EdgeInsets.all(8)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(proxyStateProvider.notifier)
                              .setProxy(proxyTextEditingController.text, portTextEditingController.text);
                          SnackBar snackBar = SnackBar(
                            backgroundColor: Colors.grey[900],
                            content: Text('Proxy enabled',
                                style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.white)),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pop(context);
                        } on PlatformException catch (e) {
                          SnackBar snackBar = SnackBar(
                            backgroundColor: Colors.grey[900],
                            content: Text('${e.message}',
                                style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.white)),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } catch (e) {
                          print(e);
                        }
                      },
                      style: Theme.of(context)
                          .elevatedButtonTheme
                          .style
                          ?.copyWith(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white)),
                      child: Text(
                        "Set",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                      )),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  child: TextButton(
                      onPressed: () async {
                        await ref.read(proxyStateProvider.notifier).setProxy("", "");
                        SnackBar snackBar = SnackBar(
                          backgroundColor: Colors.grey[900],
                          content: Text('Proxy disabled',
                              style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.white)),
                        );
                        await ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Disable proxy",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
                      )),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
