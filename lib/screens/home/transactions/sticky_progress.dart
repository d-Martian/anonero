import 'package:anon_wallet/state/node_state.dart';
import 'package:anon_wallet/state/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SyncProgressSliver extends SingleChildRenderObjectWidget {
  const SyncProgressSliver({super.key})
      : super(child: const ProgressSliverWidget());

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ProgressStickyRender();
  }
}

class ProgressSliverWidget extends ConsumerWidget {
  const ProgressSliverWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    bool isConnecting = ref.watch(connectingToNodeStateProvider);
    bool isWalletOpening = ref.watch(walletLoadingProvider) ?? false;
    bool connected = ref.watch(connectionStatus) ?? false;
    Map<String, num>? sync = ref.watch(syncProgressStateProvider);
    bool isActive = isConnecting || isWalletOpening || sync != null;

    double height = sync != null ? 44 : 14;

    return AnimatedContainer(
      color: Theme.of(context).scaffoldBackgroundColor,
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: isActive ? height : 0,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Builder(
          builder: (context) {
            if (sync != null && sync['remaining'] != 0) {
              double progress = sync['progress']?.toDouble() ?? 0.0;
              return Column(
                children: [
                  RoundedLinearProgressBar(
                    max: 1,
                    height: 4,
                    current: sync['progress']?.toDouble() ?? 0.0,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${sync['remaining']} blocks remaining",
                          style: Theme.of(context).textTheme.caption?.copyWith(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: Theme.of(context).textTheme.caption?.copyWith(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              );
            } else if (isConnecting || isWalletOpening) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  backgroundColor: Color(0xFA2A2A2A),
                  minHeight: 4,
                ),
              );
            } else {
              if (!connected) {
                return Column(
                  children: [
                    const LinearProgressIndicator(
                      minHeight: 4,
                    ),
                    const Padding(padding: EdgeInsets.all(6)),
                    Text(
                      "Disconnected",
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                );
              } else {
                return Container();
              }
            }
          },
        ),
      ),
    );
  }
}

class ProgressStickyRender extends RenderSliverSingleBoxAdapter {
  @override
  void performLayout() {
    var constraints = this.constraints;
    geometry = SliverGeometry.zero;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtend = child!.size.height ?? 0;
    geometry = SliverGeometry(
      paintExtent: childExtend,
      maxPaintExtent: childExtend,
      paintOrigin: constraints.scrollOffset,
    );
    setChildParentData(child!, constraints, geometry!);
  }
}

class RoundedLinearProgressBar extends StatelessWidget {
  final double max;
  final double current;
  final double height;

  const RoundedLinearProgressBar({
    Key? key,
    required this.max,
    required this.current,
    this.height = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, boxConstraints) {
        var x = boxConstraints.maxWidth;
        var percent = (current / max) * x;
        return Stack(
          children: [
            Container(
              width: x,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFA2A2A2A),
                borderRadius: BorderRadius.circular(height),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: percent,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ],
        );
      },
    );
  }
}
