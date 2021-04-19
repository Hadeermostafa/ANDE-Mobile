import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CounterWidget extends StatefulWidget {
  final Function onPlusPressed, onMinusPressed;
  final int counter;
  final double width, height;
  CounterWidget(
      {this.onMinusPressed,
      this.onPlusPressed,
      this.counter,
      this.width,
      this.height});

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  final Color buttonColor = Colors.grey[900];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          (LocalKeys.QUANTITY_LABEL).tr(),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
          color: Colors.white,
            borderRadius: BorderRadius.circular(widget.width / 2),
            border: Border.all(
              color: Colors.grey[300],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    alignment: AlignmentDirectional.centerStart,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    onPressed: widget.onMinusPressed,
                    icon: Icon(
                      Icons.remove_circle,
                      size: 30,
                      color: widget.onMinusPressed != null
                          ? buttonColor
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              Text(
                '${widget.counter}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton( key: Key('add item'),
                    alignment: AlignmentDirectional.centerEnd,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    onPressed: widget.onPlusPressed,
                    icon: Icon(
                      Icons.add_circle,
                      size: 30,
                      color: buttonColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
