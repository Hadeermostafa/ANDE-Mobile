import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItemViewModel orderItem;
  final kTextStyle = TextStyle(
    fontSize: 13,
    color: Colors.grey[700],
  );

  OrderItemCard({this.orderItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            spreadRadius: .5,
            blurRadius: 20,
            color: Colors.black45.withOpacity(.2),
          ),
        ], color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    orderItem.itemViewModel.name !=
                            'null'
                        ? orderItem
                                .itemViewModel.name ??
                            ''
                        : '',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                Visibility(
                  replacement: Container(
                    width: 0,
                    height: 0,
                  ),
                  visible: orderItem.quantity > 1,
                  child: Text(
                    "(x ${orderItem.quantity})",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                HelperWidget.horizontalSpacer(widthVal: 5),
                Text(
                  orderItem.mealSize.price.toString(),
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "${LocalKeys.SIZES_LABEL.tr()}:",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text(orderItem.mealSize.name),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: getMealExtras(context),
            ),
            Text(
              "${LocalKeys.NOTES_LABEL.tr()}:",
              style: TextStyle(color: Colors.grey[500]),
            ),
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Text(orderItem.userNote ?? '')),
          ],
        ),
      ),
    );
  }

  getMealExtras(context) {
    List<String> mealExtras = [];

    orderItem.userSelectedExtras.forEach((element) {
      mealExtras.add(element.name);
    });
    String extrasString = mealExtras.join(',');

    List<Widget> optionsAndExtras = [];

    if (extrasString.length > 0) {
      optionsAndExtras.add(Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('${(LocalKeys.EXTRAS_LABEL).tr()}: ',
                textScaleFactor: 1, style: kTextStyle),
            SizedBox(
              height: 2.5,
            ),
            Text(
              extrasString,
              textScaleFactor: 1,
              style: kTextStyle.copyWith(
                color: Colors.black,
              ),
            ),
          ],
        ),
        flex: 1,
      ));
    }

    return optionsAndExtras;
  }
}
