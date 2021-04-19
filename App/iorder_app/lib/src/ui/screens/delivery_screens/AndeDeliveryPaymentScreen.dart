import 'dart:io';
import 'dart:ui' as ui;

import 'package:ande_app/src/blocs/bloc/NotificationBloc.dart';
import 'package:ande_app/src/blocs/bloc/PaymentBloc.dart';
import 'package:ande_app/src/blocs/bloc/UserBloc.dart';
import 'package:ande_app/src/blocs/events/UserEvents.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Resources.dart';
import 'package:ande_app/src/resources/UserCart.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/NavigationDrawer.dart';
import 'package:ande_app/src/ui/widgets/OrderItemCard.dart';
import 'package:ande_app/src/ui/widgets/OrderStatusCard.dart';
import 'package:ande_app/src/ui/widgets/PageFooter.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart' as ll;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/animated_drawer_content.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/simple_hidden_drawer.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../../../main.dart';
import '../LandingScreen.dart';

class AndeDeliveryPaymentScreen extends StatefulWidget {
  final bool comingFromActive;
  final OrderViewModel userOrderModel;
  static const String DELIVERY_PAYMENT_KEY = "AndeDeliveryPaymentScreen";

  AndeDeliveryPaymentScreen({this.comingFromActive, this.userOrderModel});

  @override
  _AndeDeliveryPaymentScreenState createState() =>
      _AndeDeliveryPaymentScreenState();
}

class _AndeDeliveryPaymentScreenState extends State<AndeDeliveryPaymentScreen>
    with WidgetsBindingObserver {
  int _statusIndex = 1;
  PaymentBloc paymentBloc;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
     paymentBloc.add(ReloadDeliveryOrderItems());
    }
  }

  _getOrderStatus() {
    switch (paymentBloc.userOrder.statues) {
      case ORDER_STATUES.CONFIRMED:
        {
          _statusIndex = 2;
          break;
        }

      case ORDER_STATUES.ON_ITS_WAY:
        {
          _statusIndex = 3;
          break;
        }
      case ORDER_STATUES.COMPLETED:
        {
          _statusIndex = 4;
          break;
        }
      default:
        {
          _statusIndex = 1;
        }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    paymentBloc = PaymentBloc(
        BlocProvider.of<NotificationBloc>(context), widget.userOrderModel);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    paymentBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _getOrderStatus();
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: SimpleHiddenDrawer(
        typeOpen: DirectionalityHelper.getDirectionalityForLocale(
            context, ll.EasyLocalization.of(context).locale) ==
            ui.TextDirection.ltr
            ? TypeOpen.FROM_LEFT
            : TypeOpen.FROM_RIGHT,
        verticalScalePercent: 90,
        menu: NavigationDrawer(onLangChanged: onLanguageChange,),
        screenSelectedBuilder: (position, controller) {
          return Scaffold(
            appBar: AndeAppbar(
              screenTitle:
              "${LocalKeys.YOUR_ORDER_NUM.tr()} ${widget.userOrderModel.orderUserNumber}",
              hasBackButton: false,
              leading: IconButton(
                  icon: ImageIcon(AssetImage(Resources.drawerMenuIcon),
                    color: Colors.white,
                  ),
                  onPressed: () {
                    controller.toggle();
                  }),
            ),
            body: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: mediaQuery.size.height - (mediaQuery.padding.top + kToolbarHeight),
                  width: mediaQuery.size.width,
                  child: BlocConsumer(
                    listener: (context, state) async {
                      if (state is OrderClosedSuccessfully) {
                        UserCart().clearCart();
                        BlocProvider.of<UserBloc>(context).userActiveOrder = null;
                        BlocProvider.of<UserBloc>(context).add(LoadUserInformation());
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                          builder: (context) {
                            return LandingScreen();
                          },
                        ), (r) => false);
                      } else if (state is PaymentFailed) {
                        if (state.error.errorCode == HttpStatus.requestTimeout) {
                          HelperWidget.showNetworkErrorDialog(context);
                          await Future.delayed(Duration(seconds: 2), () {});
                          HelperWidget.removeNetworkErrorDialog(context);
                        } else if (state.error.errorCode ==
                            HttpStatus.serviceUnavailable) {
                          HelperWidget.showToast(
                              message: (LocalKeys.SERVER_UNREACHABLE).tr(),
                              isError: true);
                        } else if (state.error.errorCode != 401) {
                          HelperWidget.showToast(
                              message: state.error.errorMessage ?? '', isError: true);
                        }
                      }
                    },
                    bloc: paymentBloc,
                    builder: (context, state) {
                      _getOrderStatus();
                      return ModalProgressHUD(
                        progressIndicator: loadingFlare,
                        inAsyncCall:
                        state is PaymentLoading || state is OrderItemsLoadingState,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 24.0, left: 24.0, top: 15, bottom: 10),
                                  child: Text(
                                    LocalKeys.ORDER_STATUS,
                                    style: TextStyle(color: Colors.grey[800]),
                                  ).tr(),
                                ),
                                Center(
                                  child: OrderStatusWidget(
                                      statues: [
                                        ORDER_STATUES.PENDING,
                                        ORDER_STATUES.CONFIRMED,
                                        ORDER_STATUES.ON_ITS_WAY,
                                        ORDER_STATUES.COMPLETED,
                                      ],
                                      curStep: _statusIndex,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 24.0, left: 24.0, top: 8.0, bottom: 8.0),
                              child: Text(
                                LocalKeys.YOUR_REQUESTS,
                                style: TextStyle(color: Colors.grey[800]),
                              ).tr(),
                            ),
                            Expanded(
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 10),
                                  child: ListView(
                                    children: paymentBloc.userOrder.orderItems
                                        .map((orderItem) => OrderItemCard(
                                      orderItem: orderItem,
                                    ))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                            getPageFooter(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double getTotalPriceForAll(OrderViewModel _userOrderModel) {
    double orderPrice = 0.0;
    for (int i = 0; i < _userOrderModel.orderItems.length; i++) {
      orderPrice += (_userOrderModel.orderItems[i].calculateItemPrice()) ?? 0.0;
    }
    return orderPrice;
  }

  Widget _cancelOrderButton() {
    if (paymentBloc.userOrder.statues == ORDER_STATUES.CONFIRMED ||
        paymentBloc.userOrder.statues == ORDER_STATUES.COMPLETED ||
        paymentBloc.userOrder.statues == ORDER_STATUES.ACCEPTED)
      return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: GestureDetector(
        onTap: () {
          paymentBloc.add(CancelOrder(order: widget.userOrderModel));
          return;
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8)),
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: Center(child: Text(LocalKeys.CANCEL_THE_ORDER).tr()),
        ),
      ),
    );
  }

  /// TODO needs to be refactored ASAP
  Widget getPageFooter() {
    double deliveryCost = 0.0;
    if (widget.userOrderModel != null &&
        widget.userOrderModel.deliveryOrderInfo != null &&
        widget.userOrderModel.deliveryOrderInfo.deliveryCost != null)
      deliveryCost = widget.userOrderModel.deliveryOrderInfo.deliveryCost;

    double netOrderPrice = getTotalPriceForAll(widget.userOrderModel);

    double taxes = ParseHelper.parseNumber(
        ((netOrderPrice *
                    (widget.userOrderModel.restaurantViewModel
                            .restaurantTaxes ??
                        0.0 / 100)) ??
                0.0)
            .toString(),
        toDouble: true);
    double orderTotal = netOrderPrice + deliveryCost + taxes;

    return PageFooter(
      footerParameters: {
        LocalKeys.ORIGINAL_PRICE: widget.userOrderModel.subTotal,
        LocalKeys.DELIVERY_TAB: deliveryCost,
        LocalKeys.TAXES_LABEL:
            widget.userOrderModel.restaurantViewModel.restaurantTaxes ?? 0,
      },
      order: widget.userOrderModel,
      orderTotal: widget.userOrderModel.totalPrice,
      restaurantCurrency: widget
          .userOrderModel.restaurantViewModel.restaurantCurrency.currencyName,
      isPercent: false,
    );
  }

  Future<void> _onRefresh() async {
    paymentBloc.add(ReloadDeliveryOrderItems());
    return null;
  }

  onLanguageChange(String newLocale) {
    ll.EasyLocalization.of(context).locale = (Locale(newLocale));
    Constants.currentAppLocale = newLocale;
    BlocProvider.of<UserBloc>(context).languageChangeNotifier.add(true);
    setState(() {});
  }
}
