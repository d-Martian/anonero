import 'package:anon_wallet/anon_wallet.dart';
import 'package:anon_wallet/screens/home/wallet_home.dart';
import 'package:anon_wallet/widgets/number_pad.dart';
import 'package:flutter/material.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({Key? key}) : super(key: key);

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String key = "";
  String confirmKey = "";
  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (controller.page == 0) {
          return Future.value(true);
        } else {
          controller.animateToPage(0, duration: const Duration(milliseconds: 240), curve: Curves.linear);
          return Future.value(false);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Hero(
                tag: "anon_logo",
                child: SizedBox(width: 180, child: Image.asset("assets/anon_logo.png")),
              ),
              const Text("Enter your PIN"),
              Expanded(
                child: PageView(
                  controller: controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 12),
                      child: NumberPadWidget(
                        maxPinSize: maxPinSize,
                        minPinSize: minPinSize,
                        onSubmit: (String pin) {
                          setState(() {
                            key = pin;
                          });
                          controller.animateToPage(1,
                              duration: const Duration(milliseconds: 240), curve: Curves.linear);
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 12),
                      child: NumberPadWidget(
                          maxPinSize: maxPinSize,
                          value: key,
                          minPinSize: minPinSize,
                          onSubmit: (String pin) {
                            setState(() {
                              confirmKey = pin;
                              if (confirmKey == key) {
                                Navigator.pop(context, confirmKey);
                              }
                            });
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberPadWidget extends StatefulWidget {
  final int maxPinSize;
  final int minPinSize;
  final String? value;
  final void Function(String key) onSubmit;
  final void Function(String key)? onKeyPress;

  const NumberPadWidget(
      {Key? key, this.maxPinSize = 10, this.minPinSize = 4, this.value, required this.onSubmit, this.onKeyPress})
      : super(key: key);

  @override
  State<NumberPadWidget> createState() => _NumberPadWidgetState();
}

class _NumberPadWidgetState extends State<NumberPadWidget> {
  String value = '';
  bool showDoneButton = false;
  bool valueMatch = true;

  _onValueChanges() {
    setState(() {
      showDoneButton = widget.minPinSize <= value.length;
      if (widget.value != null) {
        valueMatch = widget.value!.startsWith(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 22,
          alignment: Alignment.center,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.horizontal,
            children: _buildCircles(),
          ),
        ),
        NumberPad(
          onTap: (key) {
            setState(() {
              value = "$value$key";
              _onValueChanges();
            });
            widget.onKeyPress?.call(key);
          },
          onDeleteLongPress: () {
            setState(() {
              value = "";
              _onValueChanges();
            });
          },
          onDoneCallback: () {
            widget.onSubmit(value);
          },
          onDeleteCancelTap: () {
            var values = value.split("");
            values.removeLast();
            setState(() {
              value = values.join();
              _onValueChanges();
            });
          },
          showDoneButton: showDoneButton,
          doneIcon: const Icon(Icons.done),
        ),
        const Padding(padding: EdgeInsets.all(8)),
        AnimatedSlide(
          offset: !valueMatch ? const Offset(0, 0) : const Offset(-32, 0),
          duration: const Duration(milliseconds: 100),
          child: Text("Pin does not match",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.redAccent)),
        )
      ],
    );
  }

  List<Widget> _buildCircles() {
    var list = <Widget>[];
    for (int i = 0; i < value.length; i++) {
      list.add(const Padding(
        padding: EdgeInsets.all(8.0),
        child: Circle(),
      ));
    }
    return list;
  }
}

class Circle extends StatelessWidget {
  const Circle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
          color: Theme.of(context).textTheme.bodySmall?.color,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.white, width: 1)),
    );
  }
}
