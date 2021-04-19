import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../resources/Constants.dart';

class PageFooter extends StatefulWidget {
  final double orderTotal;
  final String restaurantCurrency;
  final OrderViewModel order;
  final Map<String, dynamic> footerParameters;
  final Widget action;
  final bool isPercent;

  PageFooter({
    this.orderTotal,
    this.order,
    this.action,
    this.restaurantCurrency,
    @required this.footerParameters,
    this.isPercent = true,
  });

  @override
  _PageFooterState createState() => _PageFooterState();
}

class _PageFooterState extends State<PageFooter> {
  final double numbersFontSize = 15, labelFontSize = 11, finalFontSize = 16;
  final Color labelColor = Colors.grey;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.order.promoCodeViewModel.promoCodeTitle != null) Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(LocalKeys.TOTAL_LABEL).tr()} '
                              '(${widget.orderTotal.toStringAsFixed(2) ?? 0.0} ${widget.restaurantCurrency ?? (Constants.currentRestaurantCurrency)})',
                          textScaleFactor: 1,
                          style: TextStyle(
                              fontSize: finalFontSize,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.lineThrough
                          ),
                          textAlign: TextAlign.start,
                        ).tr(),
                        Text(
                          '${(LocalKeys.TOTAL_LABEL).tr()} '
                              '(${widget.orderTotal != null ? (widget.orderTotal - widget.order.promoCodeViewModel.discountValue).toStringAsFixed(2) : 0.0} ${widget.restaurantCurrency ?? (Constants.currentRestaurantCurrency)})',
                          textScaleFactor: 1,
                          style: TextStyle(
                            fontSize: finalFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.start,
                        ).tr()
                      ],
                    ),
                    correctVoucherCode(widget.order.promoCodeViewModel.promoCodeTitle),
                  ],
                ),
              )
              else Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: Text(
                    '${(LocalKeys.TOTAL_LABEL).tr()} '
                        '(${widget.orderTotal.toStringAsFixed(2) ?? 0.0} ${widget.restaurantCurrency ?? (Constants.currentRestaurantCurrency)})',
                    textScaleFactor: 1,
                    style: TextStyle(
                      fontSize: finalFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.start,
                  ).tr(),
                ),
              ),
              DashedDivider(
                color: Colors.grey[400],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[...getScreenParameters()],
                ),
              ),
              widget.action ?? Container(),
            ],
          ),
        ),
      ),
    );
  }

  getScreenParameters() {
    List<Widget> parameters = List();
    widget.footerParameters.forEach((key, value) {
      parameters.add(Expanded(
        flex: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            key == LocalKeys.ORIGINAL_PRICE
                ? Text(
                    '${value != null ? value.toStringAsFixed(2) : 0.0} ${ widget.restaurantCurrency ?? Constants.currentRestaurantCurrency}',
                    textScaleFactor: 1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: numbersFontSize,
                    ),
                  )
                : key == LocalKeys.DELIVERY_TAB
                    ? Text(
                        '${value ?? ''} ${widget.restaurantCurrency ?? Constants.currentRestaurantCurrency } ',
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: numbersFontSize,
                        ),
                      )
                    : key == LocalKeys.TAXES_LABEL
                        ? Text(
                            '${value ?? ''} ${widget.isPercent ? '%' : (widget.restaurantCurrency ?? '')}',
                            textAlign: TextAlign.end,
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: numbersFontSize,
                            ),
                          )
                        : Text(
                            '${value ?? ''}',
                            textAlign: TextAlign.end,
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: numbersFontSize,
                            ),
                          ),
            Text(
              key.tr() ?? '',
              textScaleFactor: 1,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: labelFontSize,
              ),
            ),
          ],
        ),
      ));
    });
    return parameters;
  }

  correctVoucherCode(String voucherCode) {
    return Chip(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Color(0xffC2EEAE),
          width: 1,
        ),
      ),
      avatar: CircleAvatar(
        radius: 10,
        backgroundColor: Color(0xff30B200),
        child: Icon(
          Icons.check,
          size: 15,
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xffEBFFE1),
      label: Text(
        voucherCode ?? '',
        textScaleFactor: 1,
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;

  const DashedDivider({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 8.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
