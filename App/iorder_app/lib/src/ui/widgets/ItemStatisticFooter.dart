import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ItemStatisticFooter extends StatelessWidget {
  final double originalPrice, restaurantTaxes, restaurantService;
  final String currency ;

  ItemStatisticFooter(
      this.currency ,
      {this.originalPrice, this.restaurantService, this.restaurantTaxes});
  final double numbersFontSize = 15, labelFontSize = 11, finalFontSize = 16;
  final Color labelColor = Colors.grey[400];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${originalPrice.toStringAsFixed(2)} $currency',
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: numbersFontSize,
                        ),
                      ),
                      Text(
                        (LocalKeys.ORIGINAL_PRICE).tr() ?? '',
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          color: labelColor,
                        ),
                      ).tr(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${restaurantService ?? ''} %',
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: numbersFontSize,
                        ),
                      ),
                      Text(
                        (LocalKeys.SERVICE_LABEL).tr(),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${restaurantTaxes.toStringAsFixed(2) ?? ''} %',
                        textAlign: TextAlign.end,
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontSize: numbersFontSize,
                        ),
                      ),
                      Text(
                        (LocalKeys.TAXES_LABEL).tr(),
                        textAlign: TextAlign.end,
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
