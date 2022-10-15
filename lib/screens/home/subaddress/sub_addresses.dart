import 'package:anon_wallet/channel/address_channel.dart';
import 'package:anon_wallet/models/sub_address.dart';
import 'package:anon_wallet/screens/home/subaddress/edit_sub_address.dart';
import 'package:anon_wallet/state/sub_addresses.dart';
import 'package:anon_wallet/theme/theme_provider.dart';
import 'package:anon_wallet/utils/monetary_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SubAddressesList extends ConsumerStatefulWidget {
  const SubAddressesList({Key? key}) : super(key: key);

  @override
  ConsumerState<SubAddressesList> createState() => _SubAddressesListState();
}

class _SubAddressesListState extends ConsumerState<SubAddressesList> {
  @override
  void initState() {
    super.initState();
    AddressChannel().getSubAddresses();
  }

  @override
  Widget build(BuildContext context) {
    var value = ref.watch(getSubAddressesProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text("SubAddresses"),
        ),
        body: value.map(
            data: (data) {
              return CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: data.value.length,
                            (context, index) {
                          SubAddress addr = data.value[index];
                          return SubAddressItem(addr);
                        },
                      ))
                ],
              );
            },
            error: (error) => Center(child: Text("Error $error")),
            loading: (c) =>
            const Center(
              child: SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(),
              ),
            )));
  }
}

class SubAddressItem extends StatelessWidget {
  final SubAddress subAddress;

  const SubAddressItem(this.subAddress, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: GestureDetector(
        onTap: () {
          showDialog(
              barrierColor: barrierColor,
              context: context,
              builder: (context) {
                return SubAddressEditDialog(subAddress);
              });
        },
        child: Text(
          subAddress.getLabel(),
          style: Theme
              .of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Theme
              .of(context)
              .primaryColor),
        ),
      ),
      subtitle: Text("${subAddress.squashedAddress}"),
      trailing: Text(
        formatMonero(subAddress.totalAmount),
        style: Theme
            .of(context)
            .textTheme
            .titleMedium,
      ),
    );
  }
}
