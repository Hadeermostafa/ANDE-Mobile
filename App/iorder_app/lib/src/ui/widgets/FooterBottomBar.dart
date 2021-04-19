import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../resources/Constants.dart';

class FooterBottomBar extends StatelessWidget {
  final double restaurantService, restaurantTaxes, orderTotal, orderSubTotal;
  final bool showTotal ;
  final bool isPercent;
  String restaurantCurrency;
  FooterBottomBar(
      {this.restaurantService,
      this.restaurantCurrency,
      this.restaurantTaxes,
      this.orderTotal,
      this.orderSubTotal,
      this.showTotal,
      this.isPercent = false,
      });
  final double numbersFontSize = 15, labelFontSize = 11, finalFontSize = 18;
  final Color labelColor = Colors.grey[400];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Constants.currentAppLocale == 'en' ? (showTotal ? 95 : 60) : (showTotal ? 113 : 75),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              spreadRadius: .5,
              blurRadius: 20,
              color: Colors.black45.withOpacity(.2),
            ),
          ],
          color: Colors.grey[200],
          border: Border(
              top: BorderSide(
            color: Colors.black12,
            width: .3,
          ))),
      child: Card(
        color: Colors.grey[200],
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
              visible: showTotal ?? true,
              replacement: SizedBox(height: 5,),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${(LocalKeys.TOTAL_LABEL).tr()} '
                        '${orderTotal.toStringAsFixed(2) ?? 0.0} ${restaurantCurrency ?? ''}',
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontSize: finalFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showTotal ?? true,
                replacement: SizedBox(height: 5,),
                child: Divider(
                  endIndent: 0,
                  indent: 0,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${orderSubTotal != null ? orderSubTotal.toStringAsFixed(2) : 0.0} ${restaurantCurrency ?? ''}',
                            textScaleFactor: 1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
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
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${restaurantTaxes ?? ''} %',
                            textAlign: TextAlign.end,
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: numbersFontSize,
                            ),
                          ),
                          Text(
                            (LocalKeys.TAXES_LABEL).tr(),
                            textScaleFactor: 1,
                            textAlign: TextAlign.end,
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
            ],
          ),
        ),
      ),
    );
  }
}
