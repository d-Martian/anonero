import 'package:flutter/material.dart';

class PolySeedWidget extends StatefulWidget {
  final String seedWords;

  const PolySeedWidget({Key? key, required this.seedWords}) : super(key: key);

  @override
  State<PolySeedWidget> createState() => _PolySeedWidgetState();
}

class _PolySeedWidgetState extends State<PolySeedWidget> {
  List<String> seeds = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      seeds = widget.seedWords.split(' ');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CustomScrollView(
        slivers: [
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('${index + 1}.'),
                      Container(
                        width: 120,
                        child: Text(
                          seeds[index],
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                      )
                    ],
                  ),
                );
              },
              childCount: seeds.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 4.0,
            ),
          )
        ],
      ),
    );
  }
}
