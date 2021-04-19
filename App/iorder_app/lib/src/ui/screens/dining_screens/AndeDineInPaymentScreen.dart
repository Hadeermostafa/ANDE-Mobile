import 'dart:io';

import 'package:ande_app/src/blocs/bloc/NotificationBloc.dart';
import 'package:ande_app/src/blocs/bloc/PaymentBloc.dart';
import 'package:ande_app/src/blocs/bloc/UserBloc.dart';
import 'package:ande_app/src/blocs/events/UserEvents.dart';
import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/PaymentMethodViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Resources.dart';
import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/resources/UserCart.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/FooterWithVoucherBottomBar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/NavigationDrawer.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:easy_localization/easy_localization.dart' as ll;
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/animated_drawer_content.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/simple_hidden_drawer.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../../../main.dart';
import '../../dialogs/AndeOnTheWayDialog.dart';
import '../../dialogs/PaymentMethodDialog.dart';
import '../LandingScreen.dart';
import 'AndeViewOrderScreen.dart';

class AndeDineInPaymentScreen extends StatefulWidget {
  final bool comingFromActive;
  static const String DINE_PAYMENT_KEY = "AndeDineInPaymentScreen";
  final OrderViewModel userOrderModel;
  AndeDineInPaymentScreen({this.comingFromActive, this.userOrderModel});

  @override
  _AndeDineInPaymentScreenState createState() => _AndeDineInPaymentScreenState();
}

class _AndeDineInPaymentScreenState extends State<AndeDineInPaymentScreen>
    with WidgetsBindingObserver {
  OrderViewModel _userOrderModel;
  PaymentBloc paymentBloc;
  bool waiterOnTheWayOnScreen = false;
  FlutterWebviewPlugin flutterWebViewPlugin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userOrderModel = widget.userOrderModel;
    paymentBloc = PaymentBloc(
        BlocProvider.of<NotificationBloc>(context), _userOrderModel);

    flutterWebViewPlugin = FlutterWebviewPlugin();
    flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if(url.contains(URL.getNonApiURL(functionName: URL.VIEW_PAYMENT_RESULT_URL))){
        Future.delayed(Duration(seconds: 2),(){
          flutterWebViewPlugin.cleanCookies();
          flutterWebViewPlugin.clearCache();
          flutterWebViewPlugin.close();

          if(url.contains("success=true")){
            Fluttertoast.showToast(
                msg: (LocalKeys.SUCCESS_PAYMENT).tr(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);

            BlocProvider.of<UserBloc>(context).add(LoadUserInformation());
            UserCart().clearCart();

            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) {
                return LandingScreen();
              },
            ), (r) => false);
            return;
          }
          else if(url.contains("success=false")){}
          else {
            UserCart().undoOrderCreation();
            Fluttertoast.showToast(
                msg: "Something is not right with accept",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      paymentBloc.add(ReloadOrderItems());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    paymentBloc.close();
    super.dispose();
  }

  onLanguageChange(String newLocale) {
    ll.EasyLocalization.of(context).locale = (Locale(newLocale));
    Constants.currentAppLocale = newLocale;
    BlocProvider.of<UserBloc>(context).languageChangeNotifier.add(true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: SimpleHiddenDrawer(
        typeOpen: DirectionalityHelper.getDirectionalityForLocale(
                    context, ll.EasyLocalization.of(context).locale) ==
                TextDirection.ltr
            ? TypeOpen.FROM_LEFT
            : TypeOpen.FROM_RIGHT,
        verticalScalePercent: 90,
        menu: NavigationDrawer(
          onLangChanged: onLanguageChange,
        ),
        screenSelectedBuilder: (position, controller) {
          return Scaffold(
            appBar: AndeAppbar(
              screenTitle: (LocalKeys.PAYMENT_SCREEN_HEADER).tr(),
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
                  child: getScreenBody(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  getScreenBody() {
    return BlocConsumer(
      listener: (context, state) async{
        if(state is PaymentWithVisaReady)  {
          Map<String,dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
          flutterWebViewPlugin.launch(state.paymentLink, hidden: false , headers: requestHeaders);
          return ;
        }
        if (state is OrderUpdatedFromNotificationState) {
          setState(() {});
        }
        else if (state is WaiterOnTheWayState) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AndeOnTheWayDialog());
        }
        else if (state is PaymentSuccess) {
          if (waiterOnTheWayOnScreen) return;
          waiterOnTheWayOnScreen = true;
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AndeOnTheWayDialog());
        }
        else if (state is OrderClosedSuccessfully) {
          try{
            UserCart().clearCart();
            BlocProvider.of<UserBloc>(context).userActiveOrder = null;
            BlocProvider.of<UserBloc>(context).add(LoadUserInformation());
          } catch(_){}
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) {
              return LandingScreen();
            },
          ), (r) => false);
          return;
        }
        else if (state is PaymentFailed) {

          if (state.error.errorCode == 404) {
            UserCart().clearCart();
            BlocProvider.of<UserBloc>(context).add(LoadUserInformation());
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) {
                return LandingScreen();
              },
            ), (r) => false);
            return;
          }


          if (state.error.errorCode == HttpStatus.requestTimeout) {
            HelperWidget.showNetworkErrorDialog(context);
            await Future.delayed(Duration(seconds: 2), () {});
            HelperWidget.removeNetworkErrorDialog(context);
          }
          else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
            HelperWidget.showToast(
                message: (LocalKeys.SERVER_UNREACHABLE).tr(),
                isError: true
            );
          }
          else if (state.error.errorCode != 401) {
            HelperWidget.showToast(
                message: state.error.errorMessage ?? '',
                isError: true
            );
          }
        }
        else if (state is PaymentMethodsSuccess) {
          _userOrderModel.restaurantViewModel.supportedPaymentMethods = state.paymentMethods;
          performPayment();
        }

        else if (state is PromoCodeSuccess) {
          _userOrderModel.promoCodeViewModel = state.promoCodeViewModel;
        }
        else if (state is PromoCodeFailure) {
          if (state.errorViewModel.errorCode == HttpStatus.requestTimeout) {
            HelperWidget.showNetworkErrorDialog(context);
            await Future.delayed(Duration(seconds: 2), () {});
            HelperWidget.removeNetworkErrorDialog(context);
            paymentBloc.add(state.failedEvent);
            return;
          }
          HelperWidget.showToast(
              message: state.errorViewModel.errorMessage,
              isError: true
          );
          return;
        }
      },
      builder: (context, state){
        if (state is OrderDataLoaded) {
          _userOrderModel = state.orderViewModel;
          UserCart().userOrderNo = _userOrderModel.orderUserNumber;
        }
        return ModalProgressHUD(
          inAsyncCall: state is PaymentLoading || state is OrderItemsLoadingState,
          progressIndicator: loadingFlare,
          child: Container(
            color: Colors.grey[300],
            child: Column(
              children: <Widget>[
                screenHeader(),
                Expanded(
                  child: Container(
                    color: Colors.black.withOpacity(.2),
                    child: Center(
                      child: FlareActor("assets/flr/ande.flr",
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          animation: "Untitled"),
                    ),
                  ),
                ),
                screenFooter(),
                screenActions(),
              ],
            ),
          ),
        );
      },
      bloc: paymentBloc,
    );
  }

  Widget screenHeader() {
    return StreamBuilder<bool>(
      initialData: true,
      stream: BlocProvider.of<UserBloc>(context).languageChangeNotifier,
      builder: (context, snapshot) {
        return Container(
          key: GlobalKey(),
          color: Colors.white,
          height: 100,
          child: Material(
            shadowColor: Colors.black.withOpacity(.2),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              (LocalKeys.ORDER_NO).tr(),
                              textScaleFactor: 1,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            HelperWidget.verticalSpacer(heightVal: 10),
                          ],
                        ),
                        Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.cover,
                              child: Text(
                                '${UserCart().userOrderNo == null ? '' : UserCart().userOrderNo.toString()}',
                                textScaleFactor: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ).tr(),
                            ),
                            HelperWidget.verticalSpacer(heightVal: 10),
                          ],
                        ),
                      ],
                    ),
                    HelperWidget.horizontalDashedLine(
                        dashesLength: 18,
                        dashesColor: Colors.grey[200],
                        dashesWith: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget screenFooter() {
    double restaurantService =
        _userOrderModel.restaurantViewModel.restaurantService ?? 0;
    double restaurantTaxes =
        _userOrderModel.restaurantViewModel.restaurantTaxes ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          child: FooterWithVoucherBottomBar(
            _userOrderModel.restaurantViewModel.restaurantCurrency.currencyName,
            orderSubTotal: _userOrderModel.subTotal,
            restaurantService: restaurantService,
            restaurantTaxes: restaurantTaxes,
            orderTotal: _userOrderModel.totalPrice,
            promoCode: _userOrderModel.promoCodeViewModel.promoCodeTitle ?? null,
            paymentState: paymentBloc.state,
            onPressed: (code){
              paymentBloc.add(ApplyPromoCodeToOrder(
                promoCode: code,
                orderType: OrderType.DINING,
              ));
              Navigator.pop(context);
            },
            context: context,
          ),
        ),
      ],
    );
  }

  double calculateOrderNetTotal(List<OrderItemViewModel> orderItems) {
    if (orderItems == null || orderItems.length == 0) return 0.0;

    double orderNet = 0.0;

    for (int i = 0; i < orderItems.length; i++)
      orderNet += orderItems[i].calculateItemPrice();

    return orderNet;
  }

  double calculateOrderGross(double netValue, double taxes, double service) {
    double orderTaxes = netValue * (taxes / 100);
    double orderService = netValue * (service / 100);

    return netValue + orderTaxes + orderService;
  }

  screenActions() {
    return StreamBuilder<bool>(
      initialData: true,
      stream: BlocProvider.of<UserBloc>(context).languageChangeNotifier,
      builder: (context, snapshot) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ButtonTheme(
                    height: 60,
                    child: RaisedButton(
                      key: GlobalKey(),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      color: Colors.grey[900],
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return BlocProvider.value(
                            value: paymentBloc,
                            child: AndeViewOrderScreen(
                              comingFromActive: false,
                            ),
                          );
                        }));
                      },
                      child: Text(
                        (LocalKeys.ORDER_DETAILS).tr(),
                        key: GlobalKey(),
                        textScaleFactor: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  HelperWidget.verticalSpacer(heightVal: 7),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: ButtonTheme(
                          height: 60,
                          child: RaisedButton(
                            key: GlobalKey(),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 0.5,
                                color: Colors.black.withOpacity(.2),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            color: Colors.white,
                            onPressed: () {
                              String restaurantId = _userOrderModel
                                  .restaurantViewModel
                                  .restaurantListViewModel
                                  .restaurantId
                                  .toString();
                              String orderId = UserCart().orderID.toString();
                              String tableNumber = UserCart().orderTableNumber.toString();
                              paymentBloc.add(RequestWaiter(
                                  restaurantId: restaurantId,
                                  orderId: orderId,
                                  tableNumber: tableNumber));
                            },
                            child: Text(
                              (LocalKeys.CALL_WAITER).tr(),
                              key: GlobalKey(),
                              textScaleFactor: 1,
                              style: TextStyle(
                                color: Colors.black.withOpacity(.8),
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                      HelperWidget.horizontalSpacer(widthVal: 7),
                      Expanded(
                        child: ButtonTheme(
                          height: 60,
                          child: RaisedButton(
                            key: GlobalKey(),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.green,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            color: Colors.green,
                            onPressed: () {
                              paymentBloc.add(RequestPaymentMethods(restaurantId: _userOrderModel.restaurantViewModel.restaurantListViewModel.restaurantId));
                            },
                            child: Text(
                              _userOrderModel.promoCodeViewModel.discountValue != null ?
                              '${(LocalKeys.PAYMENT_BUTTON_LABEL).tr()} (${((_userOrderModel.totalPrice - _userOrderModel.promoCodeViewModel.discountValue) > 0.0 ? (_userOrderModel.totalPrice - _userOrderModel.promoCodeViewModel.discountValue) : 0).toStringAsFixed(2) + ' ' + _userOrderModel.restaurantViewModel.restaurantCurrency.currencyName ?? ''})' :
                              '${(LocalKeys.PAYMENT_BUTTON_LABEL).tr()}',
                              textScaleFactor: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  openPaymentDialog() async {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return PaymentMethodDialog(
            restaurantSupportedPaymentMethods:
                _userOrderModel.restaurantViewModel.supportedPaymentMethods,
            paymentMethodSelected: onPaymentMethodSelected,
            initialPaymentMethod: null,
          );
        });
  }

  onPaymentMethodSelected(PaymentMethodViewModel paymentMethod) async {
    Navigator.pop(context);
    _userOrderModel.paymentMethod = paymentMethod;
    if(paymentMethod.paymentMethodId == 1){
      paymentBloc.add(RequestCheckEvent(paymentOrderModel: _userOrderModel));
    } else {
      if(paymentBloc.state is PaymentWithVisaReady){
        Map<String,dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
        flutterWebViewPlugin.launch((paymentBloc.state as PaymentWithVisaReady).paymentLink, hidden: false , headers: requestHeaders);
        return ;
      }
      else
       paymentBloc.add(RequestVisaPayment(paymentOrderModel: _userOrderModel));
    }
  }

  Future<void> _onRefresh() async {
    paymentBloc.add(ReloadOrderItems());
    await Future.delayed(Duration(seconds: 0));
    return null;
  }

  void performPayment() {

    if((_userOrderModel.restaurantViewModel.supportedPaymentMethods != null && _userOrderModel.restaurantViewModel.supportedPaymentMethods.isNotEmpty))
        openPaymentDialog();
    else {
      paymentBloc.add(RequestCheckEvent(paymentOrderModel: _userOrderModel));
      return;
    }
  }
}
