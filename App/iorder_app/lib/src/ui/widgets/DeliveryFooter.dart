import 'package:ande_app/src/blocs/bloc/CreateOrderBloc.dart';
import 'package:ande_app/src/blocs/events/CreateOrderEvents.dart';
import 'package:ande_app/src/blocs/states/CreateOrderStates.dart';
import 'package:ande_app/src/data_providers/models/delivery/DeliveryArea.dart';
import 'package:ande_app/src/data_providers/models/delivery/RestaurantDeliveryInformation.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryFooter extends StatefulWidget {
  double restaurantService, delivery, orderNetPrice;
  String restaurantCurrency;
  DeliveryFeesType feesType;
  DeliveryArea region;
  final bool showTotal;
  final bool toBeDetermined;
  final String promoCode;
  final Function(String code) onPressed;
  final CreateOrderStates state;

  DeliveryFooter(
      {this.restaurantService,
      this.restaurantCurrency,
      this.delivery,
      this.feesType,
      this.region,
      this.orderNetPrice,
      this.showTotal = false,
      this.toBeDetermined = false,
      this.promoCode,
      this.onPressed,
      this.state});

  @override
  _DeliveryFooterState createState() => _DeliveryFooterState();
}

class _DeliveryFooterState extends State<DeliveryFooter> {
  TextEditingController _promoCodeController = TextEditingController();
  String promoCode;

  final double numbersFontSize = 15, labelFontSize = 11, finalFontSize = 16;

  final Color labelColor = Colors.grey[400];

  @override
  void initState() {
    super.initState();
    if (widget.promoCode != null) {
      promoCode = widget.promoCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.restaurantService = widget.restaurantService ?? 0.0;
    widget.orderNetPrice = widget.orderNetPrice ?? 0.0;
    widget.delivery = widget.delivery ?? 0.0;

    String deliveryText = "";

    double orderGrossValue =
        (widget.orderNetPrice ?? 0) + (widget.orderNetPrice * widget.restaurantService / 100);
    if (widget.feesType == DeliveryFeesType.FIXED_COST) {
      orderGrossValue += widget.delivery;
      deliveryText = widget.delivery.toString() +
          " " +
          (widget.restaurantCurrency ?? '');
    } else if (widget.feesType == DeliveryFeesType.PERCENTAGE_COST) {
      orderGrossValue += (widget.orderNetPrice * widget.delivery / 100);
      deliveryText = widget.delivery.toString() + " %";
    } else {
      if (widget.region == null)
        deliveryText = (LocalKeys.TO_BE_DEFINED).tr();
      /*else {
        deliveryText = region.deliveryFees.toString() +
            " " +
            (restaurantCurrency ?? Constants.currentRestaurantCurrency);
        orderGrossValue += region.deliveryFees;
      }*/
    }

    return Container(
      height: Constants.currentAppLocale == 'en' ? (widget.showTotal ? 113 : 60) : (widget.showTotal ? 113 : 75),
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
              Visibility(
                visible: widget.showTotal ?? true,
                replacement: SizedBox(height: 0.0, width: 0.0,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.toBeDetermined ? '${tr(LocalKeys.TO_BE_DETERMINED)}' :
                        '${(LocalKeys.TOTAL_LABEL).tr()} '
                            '${orderGrossValue.toStringAsFixed(2) ?? 0.0} ${widget.restaurantCurrency ?? ''}',
                        textScaleFactor: 1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: finalFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    getVoucherCodeView(widget.state),
                  ],
                ),
              ),
              Visibility(
                visible: widget.showTotal ?? true,
                replacement: SizedBox(height: 0.0, width: 0.0,),
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
                          Expanded(
                            child: Text(
                              '${widget.orderNetPrice != null ? widget.orderNetPrice.toStringAsFixed(2) : 0.0} ${widget.restaurantCurrency}',
                              textScaleFactor: 1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: numbersFontSize,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (LocalKeys.ORIGINAL_PRICE).tr() ?? '',
                              textScaleFactor: 1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: labelFontSize,
                                color: labelColor,
                              ),
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
                          Expanded(
                            child: Text(
                              '${widget.restaurantService ?? ''} %',
                              textScaleFactor: 1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: numbersFontSize,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (LocalKeys.TAXES_LABEL).tr(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: 1,
                              style: TextStyle(
                                fontSize: labelFontSize,
                                color: labelColor,
                              ),
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
                          Expanded(
                            child: Text(
                              deliveryText,
                              textAlign: TextAlign.end,
                              textScaleFactor: 1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: numbersFontSize,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (LocalKeys.DELIVERY_TAB).tr(),
                              textScaleFactor: 1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: labelFontSize,
                                color: labelColor,
                              ),
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

  defaultVoucherCode() {
    return RaisedButton(
      elevation: 0,
      color: Colors.white,
      padding: EdgeInsets.all(8),
      onPressed: true
          ? () async {
        await showVoucherCodeDialog(context);
      }
          : null,
      child: Text(
        (widget.promoCode != null && widget.promoCode.length > 0)
            ? widget.promoCode
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
                              child: TextFormField(key: Key('code'),
                                controller: _promoCodeController,
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
                              FocusScope.of(context).unfocus();
                              widget.onPressed(_promoCodeController.text.trim());
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

  Widget getVoucherCodeView(state) {
    if (state is OrderPromoCodeValid) {
      setState(() {
        promoCode = state.promoCodeViewModel.promoCodeTitle;
      });
      return correctVoucherCode(state.promoCodeViewModel.promoCodeTitle);
    } else if (state is RemovePromoCode) {
      setState(() {
        promoCode = null;
      });
      return defaultVoucherCode();
    } else {
      return Visibility(
        visible: promoCode != null && promoCode.isNotEmpty && promoCode.length > 0,
        replacement: defaultVoucherCode(),
        child: correctVoucherCode(promoCode),
      );
    }
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
      deleteIcon: Icon(
        Icons.close,
        size: 15,
      ),
      onDeleted: () async {
        // await showVoucherCodeDialog(context);
        BlocProvider.of<CreateOrderBloc>(context).add(MoveToCreateOrderState(moveTo: RemovePromoCode()));
      },
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
    );
  }
}
