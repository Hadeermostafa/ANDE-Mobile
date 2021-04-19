import 'package:ande_app/main.dart';
import 'package:ande_app/src/ui/dialogs/NetworkErrorView.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utilities/HelperFunctions.dart';

class HelperWidget {
  static Widget horizontalSpacer({double widthVal}) {
    if (widthVal == null)
      return Container(
        width: 0,
        height: 0,
      );
    else
      return SizedBox(
        width: widthVal,
      );
  }

  static Widget verticalSpacer({double heightVal}) {
    if (heightVal == null)
      return Container(
        width: 0,
        height: 0,
      );
    else
      return SizedBox(
        height: heightVal,
      );
  }

  static Widget horizontalDashedLine(
      {Color dashesColor, int dashesLength, double dashesWith}) {
    return Flex(
      children: List.generate(dashesLength ?? 50, (_) {
        return SizedBox(
          width: dashesWith ?? 4,
          height: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: DecoratedBox(
              decoration: BoxDecoration(color: dashesColor ?? Colors.grey[300]),
            ),
          ),
        );
      }),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      direction: Axis.horizontal,
    );
  }

  static Widget verticalDashedLine(
      {Color dashesColor, int dashesLength, double dashesHeight}) {
    return Flex(
      children: List.generate(dashesLength ?? 50, (_) {
        return SizedBox(
          width: 1,
          height: dashesHeight ?? 4,
          child: DecoratedBox(
            decoration: BoxDecoration(color: dashesColor ?? Colors.grey[300]),
          ),
        );
      }),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      direction: Axis.vertical,
    );
  }

  static Widget resolveDirectionality(
      {Widget child,
      BuildContext context,
      String locale,
      String targetWidgetName}) {
    TextDirection widgetDirection =
        DirectionalityHelper.getDirectionalityForLocale(
            context, Locale(locale));

    return Directionality(
      child: child,
      textDirection: widgetDirection,
    );
  }



  static void showToast({@required String message , @required bool isError ,
    Color backgroundColor , Color textColor , Toast toastLength}){
    Fluttertoast.showToast(
        msg: message,
        toastLength: toastLength ?? Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: backgroundColor ?? isError ? Colors.red : Colors.green,
        textColor: textColor ?? Colors.white,
        fontSize: 16.0);
  }


  static void showNetworkErrorDialog(BuildContext context){
    try{
      networkError.remove();
    } catch(_){}

    Overlay.of(context).insert(networkError);
  }
  static void removeNetworkErrorDialog(BuildContext context){
    try{
      networkError.remove();
    } catch(_){}
  }


  static void showBlockingNetworkErrorDialog(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return NetworkErrorView();
        });
  }
}
