import 'dart:io';

import 'package:ande_app/src/blocs/bloc/PaymentBloc.dart';
import 'package:ande_app/src/blocs/events/CreateOrderEvents.dart' as orderEvents;
import 'package:ande_app/src/blocs/events/UserEvents.dart';
import 'package:ande_app/src/blocs/states/CreateOrderStates.dart';
import 'package:ande_app/src/blocs/states/UserStates.dart';
import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductViewModel.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/ui/dialogs/AndeOnTheWayDialog.dart';
import 'package:ande_app/src/ui/dialogs/WarningDialog.dart';
import 'package:ande_app/src/ui/list_tiles/ProductCustomizationClosedStateTile.dart';
import 'package:ande_app/src/ui/list_tiles/ProductItemCustomizationTile.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/CartItem.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../../../main.dart';
import '../../../blocs/bloc/CreateOrderBloc.dart';
import '../../../blocs/bloc/LoginBloc.dart';
import '../../../blocs/bloc/UserBloc.dart';
import '../../../blocs/events/LoginEvents.dart';
import '../../../blocs/states/LoginStates.dart';
import '../../../data_providers/models/RestaurantListViewModel.dart';
import '../../../data_providers/models/RestaurantViewModel.dart';
import '../../../resources/StarRating.dart';
import '../../../resources/UserCart.dart';
import '../../dialogs/PhoneAuthenticationDialog.dart';
import '../../dialogs/TableNumberDilaog.dart';
import '../../widgets/FooterWithVoucherBottomBar.dart';
import 'AndeDineInPaymentScreen.dart';

class OrderCartScreen extends StatefulWidget {
  final RestaurantViewModel restaurantModel;

  OrderCartScreen({this.restaurantModel});

  @override
  _OrderCartScreenState createState() => _OrderCartScreenState();
}

class _OrderCartScreenState extends State<OrderCartScreen> {
  RestaurantViewModel _restaurantModel;

  GlobalKey<AnimatedListState> animatedListController =
      GlobalKey<AnimatedListState>();

  double screenHeight = 0;
  bool isQREnabled = true;
  PersistentBottomSheetController controller;
  bool isEditingMode = false;
  int activeItemIndex = -1;

  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _listViewKey = GlobalKey();
  List<OrderItemViewModel> backupCartItems = List();

  LoginBloc _loginBloc;
  // final VoucherBloc voucherBloc = VoucherBloc();
  CreateOrderBloc _createOrderBloc;
  OrderViewModel userOrder;

  @override
  void initState() {
    super.initState();
    _createOrderBloc = CreateOrderBloc();
    this._restaurantModel = widget.restaurantModel;
    _loginBloc = LoginBloc(authenticationBloc: BlocProvider.of<UserBloc>(context).authBloc);
    UserCart().nonConfirmedItemsList.forEach((notConfirmedItem) {
      backupCartItems.add(notConfirmedItem.deepCopy());
    });
  }

  onNoteChanged(String itemNote, int itemIndex) {
    backupCartItems[itemIndex].userNote = itemNote;
  }

  itemQuantityChanged(int itemIndex, int change) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    return Scaffold(
      backgroundColor: Color(0xffF4F4F4),
      key: _scaffoldKey,
      appBar: AndeAppbar(
        screenTitle: (LocalKeys.CART_SCREEN_TITLE).tr(),
        hasBackButton: true,
        actions: <Widget>[
          FlatButton(
            child: Text(
              isEditingMode ? LocalKeys.SAVE : LocalKeys.EDIT,
              style: TextStyle(
                color: Colors.white,
              ),
            ).tr(),
            onPressed: () {
              if (isEditingMode && isValidOrderAfterEditing() == false) {
                return;
              }

              if (isEditingMode) {
                UserCart().nonConfirmedItemsList = backupCartItems;
              }
              if (isEditingMode == false) {
                showDialog(
                    context: context,
                    builder: (context) => WarningDialog(
                      message: (LocalKeys.EDIT_MUST_BE_SAVED).tr(),
                      actions: <Widget>[
                        Expanded(
                          child: ButtonTheme(
                            height: 50,
                            child: FlatButton(
                              color: Colors.grey[900],
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                LocalKeys.CONFIRM_LABEL,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ).tr(),
                            ),
                          ),
                        ),
                      ],
                    ));
              }

              isEditingMode = !isEditingMode;
              activeItemIndex =
              isEditingMode ? (backupCartItems.length - 1) : -1;
              if (backupCartItems.length == 0)
                Navigator.pop(context);
              else
                setState(() {});
            },
          ),
        ],
      ),
      body: BlocListener(
        bloc: _createOrderBloc,
        listener: (context, state) async {
          if (state is OrderCreateFailed) {
            UserCart().undoOrderCreation();
            if (state.error.errorCode == HttpStatus.requestTimeout) {
              HelperWidget.showNetworkErrorDialog(context);
              await Future.delayed(Duration(seconds: 2), () {});
              HelperWidget.removeNetworkErrorDialog(context);
              Future.delayed(Duration(seconds: 5), (){
                _createOrderBloc.add(state.failedEvent);
              });
            }
            else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
              HelperWidget.showToast(message: (LocalKeys.SERVER_UNREACHABLE).tr(), isError: true);
              return;
            }
            else if (state.error.errorCode != 401) {
              if(state.error.errorMessage.toLowerCase().contains('table')){
                UserCart().orderTableNumber = null;
                HelperWidget.showToast(message: (LocalKeys.INVALID_TABLE_NUMBER).tr(), isError: true);
                _createOrderBloc.add(orderEvents.RequestWaiter());
                return;
              }
              else
                HelperWidget.showToast(message: state.error.errorMessage, isError: true);
            }
          }
          else if (state is OrderCreateSuccess) {
            BlocProvider.of<UserBloc>(context).userActiveOrder = state.orderViewModel;
            BlocProvider.of<UserBloc>(context).add(MoveToState(wantedState: UserLoadedWithActiveOrderState(activeOrder: state.orderViewModel)));
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return BlocProvider.value(
                    value: PaymentBloc(null, null),
                    child: AndeDineInPaymentScreen(
                      userOrderModel: state.orderViewModel,
                      comingFromActive: false,
                    ),
                  );
                },
                settings: RouteSettings(name: AndeDineInPaymentScreen.DINE_PAYMENT_KEY)
              ), (route) => false,
            );
          }
          else if(state is WaiterOnItsWay){
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => AndeOnTheWayDialog());
            return;
          }
        },
        child: BlocConsumer(
          bloc: _loginBloc,
          listener: (context, state) async{
            if (state is LoginError) {
              if (state.error.errorCode == HttpStatus.requestTimeout) {
                HelperWidget.showNetworkErrorDialog(context);
                await Future.delayed(Duration(seconds: 2), () {});
                HelperWidget.removeNetworkErrorDialog(context);
              }
              else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
                Fluttertoast.showToast(
                    msg: (LocalKeys.SERVER_UNREACHABLE).tr(),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,

                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
              else if (state.error.errorCode != 401) {
                Fluttertoast.showToast(
                    msg: state.error.errorMessage ?? '',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }

            }
            else if (state is LoginSuccess) {
              // if Login is done through phone dismiss phone auth popup first
              if (state.loginMethod == LoginMethods.PHONE)
                Navigator.pop(context);
              redirectionHandler(context);
            }
          },
          builder: (context , state){
            return GestureDetector(
              onTap: () {
                if (controller != null) {
                  controller.close();
                }
              },
              child: ModalProgressHUD(
                progressIndicator: loadingFlare,
                inAsyncCall: (state is LoginLoading),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: backupCartItems.length > 0
                          ? getConfirmOrderScreenView()
                          : getEmptyCartView(),
                    ),
                    AbsorbPointer(
                      absorbing: backupCartItems.length == 0 || _createOrderBloc.state == OrderCreateLoading(),
                      child: Container(child: screenFooter()),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }







  Widget screenHeader(RestaurantListViewModel dataModel) {
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.20,
            height: MediaQuery.of(context).size.width * 0.20,
            margin: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              image: DecorationImage(
                fit: BoxFit.contain,
                image: NetworkImage(dataModel.restaurantImagePath),
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: ListTile(
              title: Text(
                dataModel.restaurantName,
                textScaleFactor: 1,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  // fontFamily: Constants.FONT_ARIAL,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    UIHelper.getCategoriesAsList(dataModel.restaurantCuisines),
                    textScaleFactor: 1,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        // fontFamily: Constants.FONT_ARIAL,
                        ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      StarRating(
                        alignment: MainAxisAlignment.start,
                        //allowHalfRating: false,
                        starCount: 5,
                        rating: 5.0,
                        //dataModel.restaurantRating * 1.0,
                        size: 20.0,
                        color: Colors.amberAccent,
                        //borderColor: Colors.amberAccent,
                        //spacing: 0.0,
                      ),
                    ],
                  ),
                  Text(
                    _restaurantModel.restaurantDescription,
                    textScaleFactor: 1,
                    textAlign: TextAlign.start,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        // fontFamily: Constants.FONT_ARIAL,
                        ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget screenFooter() {
    double originalPrice = UserCart().calculateCart();
    double finalPrice = (originalPrice +
        (originalPrice * _restaurantModel.restaurantTaxes / 100) +
        (originalPrice * _restaurantModel.restaurantService / 100));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          key: GlobalKey(),
          child: FooterWithVoucherBottomBar(
            _restaurantModel.restaurantCurrency.currencyName.toString(),
            orderSubTotal: originalPrice,
            userCanEditPromoCode: true,
            restaurantService: _restaurantModel.restaurantService,
            restaurantTaxes: _restaurantModel.restaurantTaxes,
            orderTotal: finalPrice,
            isPercent: true,
            showTotal: false,
          ),
        ),
        ButtonTheme(
          height: 60,
          minWidth: MediaQuery.of(context).size.width,
          child: FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () async {
              if (UserCart().orderID != null &&
                  UserCart().orderID.length > 0 &&
                  UserCart().nonConfirmedItemsList.length == 0) {
                String userID = (FirebaseAuth.instance.currentUser).uid;
                Navigator.pushReplacement(
                  context, MaterialPageRoute(
                    builder: (context) {
                      return BlocProvider.value(
                        value: PaymentBloc(null, null),
                        child: AndeDineInPaymentScreen(
                          userOrderModel: UserCart().createOrder(_restaurantModel, userID),
                          comingFromActive: false,
                        ),
                      );
                    },
                    settings: RouteSettings(name: AndeDineInPaymentScreen.DINE_PAYMENT_KEY)
                  ),
                );
                return;
              }
              redirectionHandler(context);
            },
            color: Colors.grey[800],
            child: SafeArea(
              child: Text(
                LocalKeys.CONFIRM_LABEL,
                textScaleFactor: 1,
                style: TextStyle(
                  fontSize: 18,
                  //fontFamily: Constants.FONT_ARIAL,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ).tr(),
            ),
          ),
        ),
      ],
    );
  }

  void showAlert(BuildContext context) async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => TableNumberDialog());
    redirectionHandler(context);
  }

  @override
  void dispose() {
    super.dispose();
  }


  void showBottomSheet() {
    controller = _scaffoldKey.currentState.showBottomSheet<Null>((context) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            // image: DecorationImage(
            //   fit: BoxFit.fill,
            //   image: AssetImage('assets/images/background.jpg'),
            // ),
        ),
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                LocalKeys.SIGN_IN_USING,
                textScaleFactor: 1,
                style: TextStyle(
                  fontSize: 18,
                  // fontFamily: Constants.FONT_ARIAL,
                  color: Colors.grey[850],
                ),
                textAlign: TextAlign.center,
              ).tr(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 70,
                    width: 70,
                    child: Center(
                      child: FlatButton.icon(
                        onPressed: () {
                          _loginBloc.add(
                              PerformLogin(loginMethod: LoginMethods.FACEBOOK));
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          MdiIcons.facebook,
                          color: Color(0xff3B5998),
                        ),
                        label: Text(''),
                      ),
                    ),
                  ),
                  Container(
                    height: 70,
                    width: 70,
                    child: Center(
                      child: FlatButton.icon(
                          onPressed: () {
//                            _loginBloc.add(
//                                PerformLogin(loginMethod: LoginMethods.PHONE));
                            Navigator.pop(context);
                            loginWithPhoneDialog();
                          },
                          icon: Icon(
                            Icons.phone_android,
                            color: Colors.black,
                          ),
                          label: Text('')),
                    ),
                  ),
                  Container(
                    height: 70,
                    width: 70,
                    child: Center(
                      child: FlatButton.icon(
                        onPressed: () {
                          _loginBloc.add(
                              PerformLogin(loginMethod: LoginMethods.TWITTER));
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          MdiIcons.twitter,
                          color: Color(0xff03A9F4),
                        ),
                        label: Text(''),
                      ),
                    ),
                  ),
                  //getAppleLogin(),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void loginWithPhoneDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return PhoneAuthenticationDialog(
            loginBloc: _loginBloc,
          );
        });
  }

  void redirectionHandler(BuildContext context) async {
    bool needLogin = Repository.isAnonymousUser();
    bool isTableSelected = (UserCart().orderTableNumber != null &&
        UserCart().orderTableNumber.length > 0);
    if (needLogin)
      showBottomSheet();
    else if (isTableSelected == false)
      showAlert(context);
    else if (needLogin == false && isTableSelected == true) {
      if (isEditingMode) {
        HelperWidget.showToast(message: (LocalKeys.SAVE_BEFORE_PLACE_ORDER).tr(), isError: true);
        return;
      }

      String userID = (FirebaseAuth.instance.currentUser).uid;
      UserCart().confirmItems();
      bool isRequestUpdateForOrder = BlocProvider.of<UserBloc>(context).userActiveOrder != null;


      if(_createOrderBloc.state is OrderCreateLoading) return;

      _createOrderBloc.add(orderEvents.CreateOrderEvent(isRequestUpdateForOrder ,orderModel: UserCart().createOrder(_restaurantModel, userID),),);
    }
  }

  getEmptyCartView() {
    return Center(
        child: FittedBox(
            child: Text(
      LocalKeys.EMPTY_CART_WARNING,
      textScaleFactor: 1,
    ).tr()));
  }

  getConfirmOrderScreenView() {
    return BlocBuilder(
      bloc: _createOrderBloc,
      builder: (context, state) {
        return ModalProgressHUD(
          progressIndicator: loadingFlare,
          inAsyncCall: state is OrderCreateLoading,
          child: ListView(
            shrinkWrap: true,
            children: [
              Divider(
                height: 1,
                color: Color(0xFFd8d8d8),
                indent: 8,
              ),
              getScreenListView(),
              HelperWidget.verticalSpacer(heightVal: 20),
            ],
          ),
        );
      },
    );
  }

  //------------------ Editing Mode -----------------------

  onTileClicked(int index) {
    activeItemIndex = index;
    setState(() {});
  }

  onSizePicked(ProductAddOn sizeViewModel, int index) {
    backupCartItems[index].mealSize = sizeViewModel;
    setState(() {});
  }

  onUpdateUserNotes(String userNote, int index) {
    backupCartItems[index].userNote = (userNote);
  }

  onDeleteItemClicked(int index) {
    backupCartItems.removeAt(index);
    animatedListController.currentState.removeItem(index, (context, index) {
      return Container();
    });

    setState(() {});
    if (backupCartItems.length > 0) {
      activeItemIndex = (backupCartItems.length - 1);
    }
  }

  onExtraUpdate(
      List<ProductAddOn> productExtras,
      int index) {
    backupCartItems[index].userSelectedExtras = productExtras;
    setState(() {});
  }

  onSilentExtraUpdate(
      List<ProductAddOn> productExtras,
      int index) {
    backupCartItems[index].userSelectedExtras = (productExtras);
  }

  getScreenListView() {
    return isEditingMode
        ? getEditingConfigurationMode()
        : getNonEditingConfigurationMode();
  }

  getEditingConfigurationMode() {
    if (backupCartItems.length == 0) {
      return getEmptyCartView();
    }
    return AnimatedList(
        primary: true,
        scrollDirection: Axis.vertical,
        key: animatedListController,
        reverse: true,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        initialItemCount: backupCartItems.length,
        itemBuilder: (context, index, animation) {
          if (index == activeItemIndex) {
            return AnimationConfiguration.staggeredList(
              child: FlipAnimation(
                flipAxis: FlipAxis.x,
                delay: Duration(seconds: 2),
                duration: Duration(milliseconds: 650),
                child: ProductItemCustomizationTile(
                  _restaurantModel.restaurantCurrency.currencyName,
                  shouldAnimate: true,
                  orderItemViewModel: backupCartItems[index],
                  itemIndex: index,
                  onItemClicked: onTileClicked,
                  onRemoveClicked: onDeleteItemClicked,
                  onEditingComplete: onUpdateUserNotes,
                  onExtraUpdate: onExtraUpdate,
                  onSilentUpdate: onSilentExtraUpdate,
                  onSizeSelected: onSizePicked,
                ),
              ),
              //position: index,
            );
          } else {
            return ProductCustomizationClosedStateTile(
              shouldAnimate: true,
              orderItemViewModel: backupCartItems[index],
              itemIndex: index,
              onItemClicked: onTileClicked,
              onItemRemoveClicked: onDeleteItemClicked,
            );
          }
        });
  }

  getNonEditingConfigurationMode() {
    return ListView.builder(
      key: _listViewKey,
      shrinkWrap: true,
      reverse: true,
      itemCount: backupCartItems.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //return Container(child: Text("index => $index vs length => ${backupCartItems.length}"),);
        // if(index >= backupCartItems.length) return Container();
        return CartItem(
          customCurrency: widget.restaurantModel.restaurantCurrency.currencyName,
          orderItem: backupCartItems[index],
        );
      },
    );
  }

  isValidOrderAfterEditing() {
    bool isValidEdit = true;
    for (int i = 0; i < backupCartItems.length; i++) {
      isValidEdit = isValidEdit && backupCartItems[i].validateItem();
      if (!isValidEdit) break;
    }
    if (isValidEdit == false) {
      HelperWidget.showToast(message: (LocalKeys.EMPTY_FIELD_REQUIRED).tr(), isError: true);
    }
    return isValidEdit;
  }

  getAppleLogin() {
    if (Platform.isIOS)
      Container(
        height: 70,
        width: 70,
        child: Center(
          child: FlatButton.icon(
            onPressed: () {
              _loginBloc.add(PerformLogin(loginMethod: LoginMethods.APPLE));
              Navigator.pop(context);
            },
            icon: Icon(
              MdiIcons.apple,
              color: Colors.grey,
            ),
            label: Text(''),
          ),
        ),
      );
    else
      return Container();
  }
}
