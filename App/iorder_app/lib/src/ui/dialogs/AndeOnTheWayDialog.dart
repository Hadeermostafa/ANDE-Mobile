
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:ande_app/main.dart';
class AndeOnTheWayDialog extends StatefulWidget {
  @override
  _AndeOnTheWayDialogState createState() => _AndeOnTheWayDialogState();
}

class _AndeOnTheWayDialogState extends State<AndeOnTheWayDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: BorderSide(
            color: Colors.grey[200],
            width: 0.5,
          )),
      contentPadding: EdgeInsets.all(8),
      content: getDialogContent(),
    );
  }

  getDialogContent() {
    return Container(
      height: 370,
      width: 150,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              HelperWidget.verticalSpacer(heightVal: 14),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      margin: EdgeInsets.only(top: 13, left: 8, right: 8),
                      child: Center(
                        child: FlareActor.asset(callWaiterBackgroundFlareProvider,
                            alignment: Alignment.center,
                            fit: BoxFit.fill,
                            animation: "Call the waiter"),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      margin: EdgeInsets.only(top: 13, left: 8, right: 8),
                      child: Center(
                        child: FlareActor.asset(callWaiterFlareProvider,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            animation: "Call the waiter"),
                      ),
                    ),
                  ],
                ),
              ),
              HelperWidget.verticalSpacer(heightVal: 10),
              Text(
                (LocalKeys.WAITER_COMING).tr(),
                textScaleFactor: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
              HelperWidget.verticalSpacer(heightVal: 5),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: IconButton(key: Key('close'),
                alignment: AlignmentDirectional.topEnd,
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.close,
                  size: 22.5,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
        ],
      ),
    );
  }
}
