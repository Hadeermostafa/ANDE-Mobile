import 'package:ande_app/src/blocs/bloc/PaymentBloc.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'HelperWidgets.dart';

class FooterWithVoucherBottomBar extends StatelessWidget {
  final double restaurantService, restaurantTaxes, orderTotal, orderSubTotal;
  final String restaurantCurrency;
  final bool userCanEditPromoCode;
  final bool isPercent;
  final bool showTotal;
  final Function(String promoCode) onPressed;
  final PaymentStates paymentState;
  final BuildContext context;
  String promoCode;
  bool canEditPromoCode = true;

  FooterWithVoucherBottomBar(
      this.restaurantCurrency,
      {this.orderSubTotal,
      this.userCanEditPromoCode,
      this.orderTotal,
      this.restaurantTaxes,
      this.restaurantService,
      this.isPercent = false,
      this.showTotal = true,
      this.onPressed,
      this.paymentState,
      this.context,
      this.promoCode}){
    PaymentStates state = this.paymentState;
    if (state is PromoCodeSuccess) {
      promoCode = state.promoCodeViewModel.promoCodeTitle;
    }
  }

  final double numbersFontSize = 15, labelFontSize = 11, finalFontSize = 16;
  final Color labelColor = Colors.grey[400];

  TextEditingController _voucherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _containerHeight = Constants.currentAppLocale == 'en' ? (showTotal ? 108 : 60) : (showTotal ? 146 : 75);
    return Container(
      height: _containerHeight,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              spreadRadius: .5,
              blurRadius: 20,
              color: Colors.black45.withOpacity(.2),
            ),
          ],
          color: Color(0xfffcfcfc),
          border: Border(
              top: BorderSide(
                color: Colors.black12,
                width: .3,
              ))),
      child: Card(
        color: Color(0xfffcfcfc),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
                visible: showTotal,
                replacement: Container(height: 0.0, width: 0.0,),
                child: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FittedBox(
                        child: Text(
                          '${(LocalKeys.TOTAL_LABEL).tr()} (${orderTotal.toStringAsFixed(2)} ${restaurantCurrency ?? ''})',
                          style: TextStyle(
                              fontSize: finalFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                              decoration: promoCode != null && promoCode.isNotEmpty && promoCode.length > 0 ?
                              TextDecoration.lineThrough : null
                          ),
                          textAlign: TextAlign.start,
                          softWrap: true,
                          textScaleFactor: 1,
                        ),
                      ),
                      getVoucherCodeView( paymentState),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible:  showTotal,
                replacement: Container(height: 0.0, width: 0.0,),
                child: HelperWidget.verticalSpacer(heightVal: 10),
              ),
              Visibility(
                visible:  showTotal,
                replacement: Container(height: 0.0, width: 0.0,),
                child: HelperWidget.horizontalDashedLine(
                  dashesColor: Colors.grey[200],
                  dashesWith: 8,
                  dashesLength: 30,
                ),
              ),
              Visibility(
                  visible:  showTotal,
                  replacement: Container(height: 0.0, width: 0.0,),
                  child: HelperWidget.verticalSpacer(heightVal: 10)
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${orderSubTotal != null ? orderSubTotal.toStringAsFixed(2) : ''} ${restaurantCurrency ?? ''}',
                            textAlign: TextAlign.start,
                            softWrap: true,
                            maxLines: 1,
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: numbersFontSize,
                            ),
                          ),
                          Text(
                            (LocalKeys.ORIGINAL_PRICE).tr() ?? '',
                            textScaleFactor: 1,
                            textAlign: TextAlign.right,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '${restaurantService ?? ''} ${ isPercent ? '%' : restaurantCurrency ?? ''}',
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${restaurantTaxes.toStringAsFixed(2) ?? ''} ${ isPercent ? '%' : restaurantCurrency ?? ''}',
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
            ],
          ),
        ),
      ),
    );
  }

  showVoucherCodeDialog(context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black.withOpacity(.2)),
              borderRadius: BorderRadius.circular(13),
            ),
            content: Material(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (LocalKeys.VOUCHER_CODE_TITLE).tr(),
                      textScaleFactor: 1,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                              padding: EdgeInsets.all(0),
                              child: TextFormField(
                                controller: _voucherController,
                              )),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            padding: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              (LocalKeys.SEND_LABEL).tr(),
                              textScaleFactor: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: (){
                               onPressed(_voucherController.text.trim());
                            },
                            elevation: 2,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  correctVoucherCode(String voucherCode) {
    return GestureDetector(
      onTap: () async {
        await showVoucherCodeDialog(context);
      },
      child: Chip(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Color(0xffC2EEAE),
            width: 1,
          ),
        ),
        deleteIconColor: Colors.grey,
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
      ),
    );
  }

  defaultVoucherCode() {
    return RaisedButton(
      elevation: 0,
      color: Colors.white,
      padding: EdgeInsets.all(8),
      onPressed: canEditPromoCode
          ? () async {
              await showVoucherCodeDialog(context);
            }
          : null,
      child: Text(
        (promoCode != null && promoCode.length > 0)
            ? promoCode
            : (LocalKeys.VOUCHER_CODE_TITLE).tr(),
        textScaleFactor: 1,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
      ),
      shape: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1,
          color: Colors.grey[300],
        ),
        borderRadius: BorderRadius.circular(8),
        gapPadding: 10,
      ),
    );
  }

  wrongVoucherCode(String voucherCode) {
    return Chip(
      padding: EdgeInsets.only(bottom: 8),
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Color(0xffd6b9b6),
            width: 1,
          )),
      deleteIcon: Icon(
        Icons.close,
        size: 15,
      ),
      onDeleted: () {},
      deleteIconColor: Colors.grey,
      avatar: CircleAvatar(
        radius: 10,
        backgroundColor: Color(0xffe63422),
        child: Icon(
          Icons.close,
          size: 15,
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xffffdfdb),
      label: Text(
        voucherCode,
        textScaleFactor: 1,
      ),
    );
  }

  Widget getVoucherCodeView(state) {
    if (state is PromoCodeSuccess) {
      promoCode = state.promoCodeViewModel.promoCodeTitle;
      return correctVoucherCode(promoCode);
    }
    else {
      return Visibility(
        visible: promoCode != null && promoCode.isNotEmpty && promoCode.length > 0,
        replacement: defaultVoucherCode(),
        child: correctVoucherCode(promoCode),
      );
    }
  }
}
