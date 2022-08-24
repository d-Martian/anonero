import 'package:flutter/material.dart';

typedef OnKeyboardTapCallBack = void Function(String key);
typedef OnDoneCallback = void Function();

class NumberPad extends StatelessWidget {
  final GestureTapCallback onDeleteCancelTap;
  final Function onDoneCallback;
  final Function onDeleteLongPress;
  final OnKeyboardTapCallBack onTap;
  final bool showDoneButton;
  final Widget doneIcon;

  const NumberPad({
    Key? key,
    required this.onDeleteCancelTap,
    required this.onDoneCallback,
    required this.onDeleteLongPress,
    required this.onTap,
    required this.showDoneButton,
    required this.doneIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _buildKeyboard(context);

  Widget _buildKeyboard(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('1', context),
            _buildKeyboardDigit('2', context),
            _buildKeyboardDigit('3', context),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('4', context),
            _buildKeyboardDigit('5', context),
            _buildKeyboardDigit('6', context),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('7', context),
            _buildKeyboardDigit('8', context),
            _buildKeyboardDigit('9', context),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: 80,
                  height: 80,
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onLongPress: () => onDeleteLongPress(),
                        highlightColor: Theme.of(context).scaffoldBackgroundColor,
                        splashColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
                        onTap: onDeleteCancelTap,
                        child: const Center(
                          child: Icon(Icons.backspace),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(child: _buildKeyboardDigit('0', context)),
            Align(
              alignment: Alignment.topRight,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                scale: showDoneButton ? 1 : 0,
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: 80,
                  height: 80,
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        highlightColor: Theme.of(context).primaryColor.withOpacity(0.5),
                        splashColor: Theme.of(context).primaryColor,
                        onTap: () => onDoneCallback(),
                        child: Center(child: doneIcon),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyboardDigit(String text, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
//        border: Border.all(color: Colors.white, width: 1),
      ),
      child: ClipOval(
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: InkWell(
            highlightColor: Theme.of(context).primaryColor.withOpacity(0.8),
            splashColor: Theme.of(context).primaryColor,
            onTap: () {
              onTap(text);
            },
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w400, color: Theme.of(context).textTheme.titleMedium?.color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
