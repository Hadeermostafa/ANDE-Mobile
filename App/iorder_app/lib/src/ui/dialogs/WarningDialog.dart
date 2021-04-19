import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WarningDialog extends StatefulWidget {
  final List<Widget> actions;
  final String message, title;
  WarningDialog({this.actions, this.message, this.title});

  @override
  _WarningDialogState createState() => _WarningDialogState();
}

class _WarningDialogState extends State<WarningDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(
          color: Colors.transparent,
          width: 1,
        ),
      ),
      title: Text(widget.title ?? ''),
      actions: [],
      elevation: 2,
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              "assets/images/wanring_icon.png",
              height: 100,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              widget.message ?? '',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.actions,
            ),
          ],
        ),
      ),
    );
  }
}
