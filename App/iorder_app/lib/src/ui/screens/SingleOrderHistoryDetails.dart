import 'dart:io';

import 'package:ande_app/main.dart';
import 'package:ande_app/src/blocs/bloc/OrderHistoryBloc.dart';
import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/PromocodeViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/PageFooter.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SingleOrderHistoryDetails extends StatefulWidget {
  final OrderViewModel orderViewModel;
  final HistoryType orderType;

  SingleOrderHistoryDetails({@required this.orderViewModel, @required this.orderType});

  @override
  _SingleOrderHistoryDetailsState createState() =>
      _SingleOrderHistoryDetailsState();
}

class _SingleOrderHistoryDetailsState extends State<SingleOrderHistoryDetails> {
  OrderHistoryBloc _historyBloc;

  @override
  void initState() {
    super.initState();
    _historyBloc = BlocProvider.of<OrderHistoryBloc>(context);
    _historyBloc
        .add(GetHistoryOrderDetails(orderId: widget.orderViewModel.orderID, orderType: widget.orderType));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AndeAppbar(
        hasBackButton: true,
        screenTitle: widget.orderViewModel.restaurantViewModel
            .restaurantListViewModel.restaurantName,
      ),
      body: BlocConsumer(
        bloc: _historyBloc,
        listener: (context, state) async {
          if (state is OrderHistoryFailed) {
            if (state.errorViewModel.errorCode == HttpStatus.requestTimeout) {
              HelperWidget.showNetworkErrorDialog(context);
              await Future.delayed(Duration(seconds: 2), () {});
              HelperWidget.removeNetworkErrorDialog(context);

              _resolveNeedRedispatch(state.failedEvent);
              return;
            } else if (state.errorViewModel.errorCode == HttpStatus.serviceUnavailable) {
              HelperWidget.showToast(message: (LocalKeys.SERVER_UNREACHABLE).tr(), isError: true);
            }
            else {
              HelperWidget.showToast(message: state.errorViewModel.errorMessage ?? '' , isError: true);
            }
          }
        },
        builder: (context, state) {
          return ModalProgressHUD(
              progressIndicator: loadingFlare,
              inAsyncCall: state is OrderHistoryLoading,
              child: _resolveChild(state));
        },
      ),
    );
  }

  Widget _resolveChild(OrderHistoryState state) {
    if (state is OrderHistoryDetailsSuccess) {
      return _getOrderBody(state.orderViewModel);
    } else if (state is OrderHistoryFailed) {
      return buildError(context, FlutterErrorDetails());
    }
    return Container();
  }

  Widget _getOrderBody(OrderViewModel orderViewModel) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          child: ListView(
            primary: true,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              Container(
                padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0, bottom: 8.0),
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      tr(LocalKeys.ORDER_SCREEN_TITLE),
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                    AutoSizeText(
                      '${_getItemsTotal(orderViewModel.orderItems).toStringAsFixed(2)} ${orderViewModel.restaurantViewModel.restaurantCurrency.currencyName ?? ''}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2b9100)),
                    ),
                  ],
                ),
              ),
              Container(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  primary: false,
                  shrinkWrap: true,
                  itemCount: orderViewModel.orderItems.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 0.0002,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      orderViewModel
                                          .orderItems[index].itemViewModel.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${orderViewModel.restaurantViewModel.restaurantCurrency.currencyName ?? ''} ${orderViewModel.orderItems[index].calculateItemPrice().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: RichText(
                                  text: TextSpan(
                                      text: '${tr(LocalKeys.SIZES_LABEL)}: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${orderViewModel.orderItems[index].mealSize.name}',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: orderViewModel.orderItems[index]
                                                  .userSelectedExtras.isEmpty
                                              ? ''
                                              : ', ',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: orderViewModel.orderItems[index]
                                                  .userSelectedExtras.isEmpty
                                              ? ''
                                              : '${tr(LocalKeys.OPTIONS_LABEL)}: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color: Colors.grey),
                                        ),
                                        TextSpan(
                                          text: orderViewModel.orderItems[index]
                                                  .userSelectedExtras.isEmpty
                                              ? ''
                                              : _getExtrasAsString(
                                                  orderViewModel
                                                      .orderItems[index],
                                                ),
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ]),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Text(
                                  '${tr(LocalKeys.NOTES_LABEL)}:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Text(
                                    orderViewModel.orderItems[index].userNote ??
                                        '${tr(LocalKeys.NONE_LABEL)}',
                                    style: TextStyle(height: 1.2)),
                              ),
                              Visibility(
                                visible: false,
                                replacement: Container(height: 0.0, width: 0.0,),
                                child: SizedBox(
                                  height: 10,
                                ),
                              ),
                              Visibility(
                                visible: false,
                                replacement: Container(height: 0.0, width: 0.0,),
                                child: ButtonTheme(
                                  height: 50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0)),
                                  child: FlatButton(
                                    child: Text(
                                      tr(LocalKeys.REORDER_LABEL),
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    color: Colors.grey[900],
                                    onPressed: () async {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            height: 100.0,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: orderViewModel.otherPeopleOrderItems != null &&
                  orderViewModel.otherPeopleOrderItems.length > 0,
                replacement: Container(height: 0.0, width: 0.0,),
                child: Container(
                  padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0, bottom: 8.0),
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        tr(LocalKeys.OTHER_ORDERS_LABEL),
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ),
                      AutoSizeText(
                        '${_getItemsTotal(orderViewModel.otherPeopleOrderItems).toStringAsFixed(2)} ${orderViewModel.restaurantViewModel.restaurantCurrency.currencyName ?? ''}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2b9100)),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: orderViewModel.otherPeopleOrderItems != null &&
                  orderViewModel.otherPeopleOrderItems.length > 0,
                replacement: Container(height: 0.0, width: 0.0,),
                child: Container(
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    itemCount: orderViewModel.otherPeopleOrderItems.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 0.0002,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        orderViewModel
                                            .otherPeopleOrderItems[index]
                                            .itemViewModel
                                            .name,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${orderViewModel.restaurantViewModel.restaurantCurrency.currencyName ?? ''} ${orderViewModel.otherPeopleOrderItems[index].calculateItemPrice().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: RichText(
                                    text: TextSpan(
                                        text: '${tr(LocalKeys.SIZES_LABEL)}: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.grey),
                                        children: [
                                          TextSpan(
                                            text:
                                                '${orderViewModel.otherPeopleOrderItems[index].mealSize.name}',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          TextSpan(
                                            text: orderViewModel
                                                    .otherPeopleOrderItems[index]
                                                    .userSelectedExtras
                                                    .isEmpty
                                                ? ''
                                                : ', ',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          TextSpan(
                                            text: orderViewModel
                                                    .otherPeopleOrderItems[index]
                                                    .userSelectedExtras
                                                    .isEmpty
                                                ? ''
                                                : '${tr(LocalKeys.OPTIONS_LABEL)}: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.grey),
                                          ),
                                          TextSpan(
                                            text: orderViewModel
                                                    .otherPeopleOrderItems[index]
                                                    .userSelectedExtras
                                                    .isEmpty
                                                ? ''
                                                : _getExtrasAsString(
                                                    orderViewModel
                                                        .otherPeopleOrderItems[index],
                                                  ),
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: Text(
                                    '${tr(LocalKeys.NOTES_LABEL)}:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.grey),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: Text(
                                    orderViewModel.otherPeopleOrderItems[index]
                                            .userNote ??
                                        '${tr(LocalKeys.NONE_LABEL)}',
                                    style: TextStyle(height: 1.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _screenFooter(orderViewModel),
        ),
      ],
    );
  }

  double _getItemsTotal(List<OrderItemViewModel> ordersList) {
    double sum = 0;
    for (int i = 0; i < ordersList.length; i++) {
      sum += ordersList[i].calculateItemPrice();
    }
    return sum;
  }

  String _getExtrasAsString(OrderItemViewModel orderItemViewModel) {
    if (orderItemViewModel.userSelectedExtras == null ||
        orderItemViewModel.userSelectedExtras.isEmpty) return "";
    List<String> optionsList = List();

    for (int i = 0; i < orderItemViewModel.userSelectedExtras.length; i++) {
      optionsList.add('(${orderItemViewModel.userSelectedExtras[i].name})');
    }
    return optionsList.join('');
  }

  Widget _screenFooter(OrderViewModel orderViewModel) {
    return Container(
      child: Visibility(
        visible: widget.orderType == HistoryType.DINE_IN,
        replacement: PageFooter(
          footerParameters: {
            LocalKeys.ORIGINAL_PRICE: orderViewModel.subTotal,
            LocalKeys.DELIVERY_TAB: orderViewModel.deliveryOrderInfo.deliveryCost,
            LocalKeys.TAXES_LABEL:
              orderViewModel.restaurantViewModel.restaurantTaxes ?? 0,
          },
          order: orderViewModel,
          orderTotal: orderViewModel.totalPrice,
          restaurantCurrency: widget.orderViewModel.restaurantViewModel.restaurantCurrency.currencyName,
          isPercent: false,
        ),
        child: HistoryFooterBottomBar(
          orderSubTotal: orderViewModel.subTotal,
          orderTotal: orderViewModel.totalPrice,
          restaurantService: orderViewModel.restaurantViewModel.restaurantService,
          restaurantTaxes: orderViewModel.restaurantViewModel.restaurantTaxes,
          restaurantCurrency: orderViewModel.restaurantViewModel.restaurantCurrency.currencyName,
          promoCodeViewModel: orderViewModel.promoCodeViewModel,
        ),
      ),
    );
  }
  
  void _resolveNeedRedispatch(OrderHistoryEvent failedEvent) {
    if (failedEvent is GetHistoryOrderDetails) {
      _historyBloc.add(failedEvent);
      return;
    }  
  }
}

class HistoryFooterBottomBar extends StatelessWidget {
  final double restaurantService, restaurantTaxes, orderTotal, orderSubTotal;
  final PromoCodeViewModel promoCodeViewModel;
  String restaurantCurrency;
  HistoryFooterBottomBar(
      {this.restaurantService,
        this.restaurantCurrency,
        this.restaurantTaxes,
        this.orderTotal,
        this.orderSubTotal,
        this.promoCodeViewModel,
      });
  final double numbersFontSize = 15, labelFontSize = 11, finalFontSize = 18;
  final Color labelColor = Colors.grey[400];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Constants.currentAppLocale == 'en' ? (promoCodeViewModel.promoCodeTitle != null ? 120 : 95) : (promoCodeViewModel.promoCodeTitle != null ? 160 : 113),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              spreadRadius: .5,
              blurRadius: 20,
              color: Colors.black45.withOpacity(.1),
            ),
          ],
          color: Colors.white,
          border: Border(
              top: BorderSide(
                color: Colors.black12,
                width: .3,
              ))),
      child: Card(
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (promoCodeViewModel.promoCodeTitle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${(LocalKeys.TOTAL_LABEL).tr()} '
                                '${orderTotal.toStringAsFixed(2) ?? 0.0} ${restaurantCurrency ?? ''}',
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: finalFontSize,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.lineThrough,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            '${(LocalKeys.TOTAL_LABEL).tr()} '
                                '${(orderTotal - promoCodeViewModel.discountValue).toStringAsFixed(2) ?? 0.0} ${restaurantCurrency ?? ''}',
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: finalFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      correctVoucherCode(promoCodeViewModel.promoCodeTitle),
                    ],
                  ),
                )
              else
                Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
              ),
              Divider(
                endIndent: 0,
                indent: 0,
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
                            '${restaurantService ?? ''} ${restaurantCurrency ?? ''}',
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
                            '${restaurantTaxes ?? ''} ${restaurantCurrency ?? ''}',
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
