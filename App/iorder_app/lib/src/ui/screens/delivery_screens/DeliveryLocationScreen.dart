import 'dart:io';

import 'package:ande_app/src/blocs/bloc/CreateOrderBloc.dart';
import 'package:ande_app/src/blocs/bloc/PaymentBloc.dart';
import 'package:ande_app/src/blocs/bloc/UserBloc.dart';
import 'package:ande_app/src/blocs/events/CreateOrderEvents.dart';
import 'package:ande_app/src/blocs/events/UserEvents.dart';
import 'package:ande_app/src/blocs/states/CreateOrderStates.dart';
import 'package:ande_app/src/blocs/states/UserStates.dart';
import 'package:ande_app/src/data_providers/models/CustomerAddressViewModel.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/data_providers/models/PaymentMethodViewModel.dart';
import 'package:ande_app/src/data_providers/models/PromocodeViewModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/DeliveryArea.dart';
import 'package:ande_app/src/data_providers/models/delivery/DeliveryOrderExtraInformationModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/RestaurantDeliveryInformation.dart';
import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/resources/UserCart.dart';
import 'package:ande_app/src/resources/external_resource/RadioButtonListTile.dart';
import 'package:ande_app/src/ui/screens/delivery_screens/AndeDeliveryPaymentScreen.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/DeliveryFooter.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ande_app/src/resources/external_resource/phone_input/international_phone_input.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../main.dart';
import 'AddNewAddressScreen.dart';

class DeliveryLocationScreen extends StatefulWidget {
  final RestaurantViewModel restaurant;
  final List<String> supportedCountriesCode = ['+966', '+20'];

  DeliveryLocationScreen({this.restaurant});

  @override
  _DeliveryLocationScreenState createState() => _DeliveryLocationScreenState();
}

class _DeliveryLocationScreenState extends State<DeliveryLocationScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PaymentMethodViewModel paymentMethod;
  CustomerAddressViewModel userLocation;
  DeliveryArea restaurantRegion;

  PaymentBloc paymentBloc ;
  List<PaymentMethodViewModel> paymentMethods = [];
  BehaviorSubject<bool> isValidPhoneNumber = BehaviorSubject<bool>();
  TextEditingController _userName = TextEditingController();
  TextEditingController _deliveryNotes = TextEditingController();
  String phoneNumber;
  String phoneIsoCode = '';
  final flutterWebViewPlugin = new FlutterWebviewPlugin();
  OrderViewModel order ;  // late initialized object when the user presses create Order
  bool paymentMethodLoading = false;
  PromoCodeViewModel _promoCodeViewModel = PromoCodeViewModel();
  List<CustomerAddressViewModel> _locations;

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    try {
      phoneNumber = internationalizedPhoneNumber;
      phoneIsoCode = isoCode;
      isValidPhoneNumber.sink.add(number != null && number.length > 0);
    } catch (exception) {
      isValidPhoneNumber.sink.add(false);
    }
  }

  @override
  void dispose() {
    isValidPhoneNumber.close();
    paymentBloc.close();
    super.dispose();
  }

  final bgColor = Color.fromARGB(100, 252, 252, 252);
  final whiteColor = Colors.white;
  final greyColor = Color(0xff707070);
  final BoxShadow boxShadow = BoxShadow(
    spreadRadius: 0,
    blurRadius: 10,
    color: Colors.black45.withOpacity(.2),
  );
  static const double screenPadding = 16.0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    if (BlocProvider.of<UserBloc>(context).userCountry.countryDialCode != null) {
      phoneIsoCode = BlocProvider.of<UserBloc>(context).userCountry.countryDialCode;
    }
    super.initState();
    paymentBloc = PaymentBloc(null , null);
    initScreenFields();
    flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if(url.contains(URL.getNonApiURL(functionName: URL.VIEW_PAYMENT_RESULT_URL))){
        Future.delayed(Duration(seconds: 0),(){
          flutterWebViewPlugin.cleanCookies();
          flutterWebViewPlugin.close();
          if(url.contains("success=true")){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> AndeDeliveryPaymentScreen(comingFromActive: false, userOrderModel: order,),),);
          }
          else if(url.contains("success=false")){
            UserCart().undoOrderCreation();
            HelperWidget.showToast(
                message: (LocalKeys.PAYMENT_FAILED).tr(), isError: true);
          }
          else {
            UserCart().undoOrderCreation();
            HelperWidget.showToast(message: "Something is not right with accept", isError: true);
          }
        });
      }
    });
    _checkForOtherAddresses(LocalKeys.OTHER_ADDRESSES_AVAILABLE);
    /// uncomment when payment methods are added to the system
    // paymentBloc.add(RequestPaymentMethods(restaurantId: widget.restaurant.restaurantListViewModel.restaurantId.toString()));
    // paymentMethodLoading = true;
  }

  void _checkForOtherAddresses(String message) {
    List<CustomerAddressViewModel> supportedLocations = [];
    BlocProvider.of<UserBloc>(context).currentLoggedInUser.userLocations.forEach((e) {
      if (isAddressSupported(e, widget.restaurant.deliveryInformation.deliveryAreas)) {
        supportedLocations.add(e);
      }
    });
    if (BlocProvider.of<UserBloc>(context).currentLoggedInUser.userLocations.length > 0 && (supportedLocations.length < BlocProvider.of<UserBloc>(context).currentLoggedInUser.userLocations.length)) {
      HelperWidget.showToast(
          message: tr(message),
          isError: false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    flutterWebViewPlugin.close();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AndeAppbar(
        screenTitle:(LocalKeys.CHECKOUT_SCREEN_TITLE).tr(),
        hasBackButton:true,
      ),
      body: BlocListener(
        bloc: paymentBloc,
        listener: (context, paymentBlocState) async{
          if(paymentBlocState is PaymentWithVisaReady)  {
            Map<String,dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
            flutterWebViewPlugin.launch(paymentBlocState.paymentLink, hidden: false , headers: requestHeaders);
            return ;
          }
          if (paymentBlocState is PaymentMethodsSuccess) {
            setState(() {
              paymentMethods = paymentBlocState.paymentMethods;
              paymentMethodLoading = false;
            });
          }
        },
        child: BlocConsumer(
          builder: (context, state) {
            return ModalProgressHUD(
              progressIndicator: loadingFlare,
              inAsyncCall: state is OrderCreateLoading || paymentMethodLoading,
              child: GestureDetector(
                onTap: (){
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(key: Key('checkout'),
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: screenPadding),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            boxShadow: [
                              boxShadow,
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  HelperWidget.verticalSpacer(heightVal: 10),
                                  Text(
                                    '${(LocalKeys.YOUR_NAME).tr()}*',
                                    style: TextStyle(color: greyColor),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    child: TextFormField(key: Key('name'),
                                      controller: _userName,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(0),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: greyColor,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: greyColor,
                                          ),
                                        ),
                                      ),
                                      validator: (inputText) {
                                        return inputText == null ||
                                                inputText.isEmpty
                                            ? (LocalKeys.REQUIRED_LABEL).tr()
                                            : null;
                                      },
                                    ),
                                  ),
                                  HelperWidget.verticalSpacer(heightVal: 10),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: InternationalPhoneInput(
                                        errorText:
                                            (LocalKeys.INVALID_PHONE_FORMAT).tr(),
                                        onPhoneNumberChange: onPhoneNumberChange,
                                        initialPhoneNumber: phoneNumber,
                                        initialSelection: phoneIsoCode,
                                        enabledCountries:
                                            widget.supportedCountriesCode),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: StreamBuilder(
                                      stream: isValidPhoneNumber,
                                      initialData: false,
                                      builder: (context, snapshot) {
                                        return Icon(
                                            snapshot.data
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: snapshot.data
                                                ? Colors.green
                                                : Colors.red);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                        HelperWidget.verticalSpacer(heightVal: 20.0),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: screenPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                (LocalKeys.YOUR_ADDRESS).tr(),
                                textScaleFactor: 1,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                              Visibility(
                                replacement: Container(
                                  width: 0,
                                  height: 0,
                                ),
                                visible: BlocProvider.of<UserBloc>(context)
                                            .currentLoggedInUser
                                            .userLocations !=
                                        null &&
                                    BlocProvider.of<UserBloc>(context)
                                            .currentLoggedInUser
                                            .userLocations
                                            .length >
                                        0,
                                child: Container(
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: _addNewAddress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            (LocalKeys.ADD_NEW_ADDRESS).tr(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        HelperWidget.verticalSpacer(heightVal: 20.0),
                        Container(
                          decoration: BoxDecoration(
                            color: whiteColor,
                            boxShadow: [
                              boxShadow,
                            ],
                          ),
                          child: Visibility(
                            visible: BlocProvider.of<UserBloc>(context)
                                        .currentLoggedInUser
                                        .userLocations !=
                                    null &&
                                BlocProvider.of<UserBloc>(context)
                                        .currentLoggedInUser
                                        .userLocations
                                        .length >
                                    0,
                            replacement: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: screenPadding),
                              height: 90,
                              child: Center(
                                child: GestureDetector(
                                  onTap: _addNewAddress,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xff333333),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (LocalKeys.ADD_YOUR_ADDRESS).tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            child: Visibility(
                              visible: getAddressesAsList().length > 0,
                              replacement: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Center(
                                  child: Text(
                                    (LocalKeys.NO_ADDRESSES_MATCH).tr(),
                                    style: TextStyle(
                                      color: Colors.grey[900],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              child: ListView(
                                  padding: EdgeInsets.all(0),
                                  children: getAddressesAsList(),
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true),
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              false, //widget.restaurant.deliveryInformation.feesType == DeliveryFeesType.AREA_BASED,
                          replacement: Container(
                            width: 0,
                            height: 0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              HelperWidget.verticalSpacer(heightVal: 20.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: screenPadding),
                                child: Text(
                                  (LocalKeys.RESTAURANT_SUPPORTED_REGIONS).tr(),
                                  textScaleFactor: 1,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              HelperWidget.verticalSpacer(heightVal: 20.0),
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    boxShadow: [
                                      boxShadow,
                                    ],
                                  ),
                                  child: ListView(
                                      padding: EdgeInsets.all(0),
                                      children: getRestaurantsRegionsAsList(),
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true)),
                            ],
                          ),
                        ),
                        HelperWidget.verticalSpacer(heightVal: 20.0),
                        /// uncomment when delivery supports payment methods
                        /*Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: screenPadding),
                          child: Text(
                            (LocalKeys.PAYMENT_METHOD).tr(),
                            textScaleFactor: 1,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                        HelperWidget.verticalSpacer(heightVal: 20.0),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              boxShadow: [
                                boxShadow,
                              ],
                            ),
                            child: ListView(
                                padding: EdgeInsets.all(0),
                                children: getPaymentMethodsAsList(),
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true)),*/
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenPadding, vertical: 16),
                          color: whiteColor,
                          child: Text(
                            (LocalKeys.DELIVERY_NOTE).tr(),
                            textScaleFactor: 1,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: screenPadding - 8),
                          child: TextFormField( key: Key('note'),
                            maxLines: 3,
                            controller: _deliveryNotes,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: whiteColor,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(
                                  width: .5,
                                  color: Colors.grey[400],
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(
                                  width: .5,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                        ),
                        getDeliveryFooter(),
                        ButtonTheme(
                          height: 60,
                          minWidth: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: FlatButton(key: Key('confirm'),
                                padding: EdgeInsets.all(0),
                                onPressed: (){
                                  FocusScope.of(context).unfocus();
                                  _createOrder();
                                  return;
                                },
                                color: Colors.grey[800],
                                child: Text(
                                  LocalKeys.CONFIRM_LABEL,
                                  textScaleFactor: 1,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ).tr(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          listener: (context, state) async{
            if (state is OrderCreateSuccess) {
              BlocProvider.of<UserBloc>(context).userActiveOrder = state.orderViewModel;
              BlocProvider.of<UserBloc>(context).add(MoveToState(wantedState: UserLoadedWithActiveOrderState(activeOrder: state.orderViewModel)));
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) {
                    return AndeDeliveryPaymentScreen(
                      comingFromActive: false,
                      userOrderModel: state.orderViewModel,
                    );
                  },
                  settings: RouteSettings(name: AndeDeliveryPaymentScreen.DELIVERY_PAYMENT_KEY)
              ), (route) => false,
              );
              return ;
            }
            else if (state is OrderCreateFailed)  {
              UserCart().undoOrderCreation();
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
              else if (state.error.errorCode == HttpStatus.internalServerError) {
                /// check with team if this is valid later on
                HelperWidget.showToast(
                    message: (LocalKeys.NO_DELIVERY_REGIONS).tr(),
                    isError: true
                );
              }
              else if (state.error.errorCode != 401) {
                HelperWidget.showToast(
                    message: state.error.errorMessage ?? '',
                    isError: true
                );
              }
            } else if (state is OrderPromoCodeValid){
              setState(() {
                _promoCodeViewModel = state.promoCodeViewModel;
              });
              return;
            } else if (state is OrderPromoCodeInvalid) {
              HelperWidget.showToast(
                  message: state.errorViewModel.errorMessage ?? '',
                  isError: true
              );
              return;
            } else if (state is RemovePromoCode) {
              setState(() {
                _promoCodeViewModel.promoCodeTitle = null;
              });
            }
          },
          bloc: BlocProvider.of<CreateOrderBloc>(context),
        ),
      ),
    );
  }
  List<Widget> getPaymentMethodsAsList() {
    List<Widget> widgetsList = List();
    for (int i = 0; i < paymentMethods.length; i++) {
      widgetsList.add(
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            boxShadow: [
              boxShadow,
            ],
          ),
          height: 70,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RadioButtonListTile(
              key: GlobalKey(),
              dense: false,
              title: Text(
                paymentMethods[i].paymentMethodName,
                textScaleFactor: 1,
              ),
              value: paymentMethods[i],
              groupValue: paymentMethod,
              activeColor: Colors.grey[900],
              onChanged: (val) {
                paymentMethod = val;
                setState(() {});
              },
            ),
          ),
        ),
      );
      if (i < (paymentMethods.length - 1)) {
        widgetsList.add(SizedBox(height: 8.0,));
      }
    }

    return widgetsList;
  }

  List<Widget> getAddressesAsList() {
    _locations =
        BlocProvider.of<UserBloc>(context).currentLoggedInUser.userLocations;

    List<Widget> widgetsList = List();
    for (int i = 0; i < _locations.length; i++) {
      if (isAddressSupported(
          _locations[i], widget.restaurant.deliveryInformation.deliveryAreas)) {
        widgetsList.add(
          Container(
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                boxShadow,
              ],
            ),
            // height: 70,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RadioButtonListTile(
                key: GlobalKey(),
                dense: false,
                title: Flexible(
                  child: Text(
                    _locations[i].toString(),
                    textScaleFactor: 1,
                    // softWrap: false,
                    // overflow: TextOverflow.fade,
                  ),
                ),
                value: _locations[i],
                groupValue: userLocation,
                activeColor: Colors.grey[900],
                onChanged: (val) {
                  userLocation = val;

                  try {
                    restaurantRegion = widget
                        .restaurant.deliveryInformation.deliveryAreas
                        .firstWhere((element) =>
                    userLocation.areaViewModel.areaId ==
                        element.regionId);
                  } catch (exception) {}
                  setState(() {});
                },
              ),
            ),
          ),
        );
        if (i < (_locations.length - 1)) {
          widgetsList.add(SizedBox(height: 8.0,));
        }
      }
    }
    return widgetsList;
  }

  List<Widget> getRestaurantsRegionsAsList() {
    List<DeliveryArea> regions =
        widget.restaurant.deliveryInformation.deliveryAreas;

    List<Widget> widgetsList = List();
    for (int i = 0; i < regions.length; i++)
      widgetsList.add(
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            boxShadow: [
              boxShadow,
            ],
          ),
          height: 70,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RadioButtonListTile(
              key: GlobalKey(),
              dense: false,
              title: Text(
                regions[i].toString(),
                textScaleFactor: 1,
              ),
              value: regions[i],
              groupValue: restaurantRegion,
              activeColor: Colors.grey[900],
              onChanged: (val) {
                restaurantRegion = val;
                setState(() {});
              },
            ),
          ),
        ),
      );
    return widgetsList;
  }

  void _createOrder() async {
    /// uncomment when delivery supports payment methods
    if (_formKey.currentState.validate() && userLocation != null && /*paymentMethod != null &&*/ isValidPhoneNumber.value) {
      /*if (int.parse(paymentMethod.paymentMethodId.toString()) != 1 ) {
        HelperWidget.showToast(
            message: tr(LocalKeys.ONLY_CASH),
            isError: true);
        return;
      }*/
      String userID = FirebaseAuth.instance.currentUser.uid;
      UserCart().confirmItems();
      order = UserCart().createOrder(widget.restaurant, userID);
      order.deliveryOrderInfo = DeliveryOrderExtraInformationModel();
      order.deliveryOrderInfo.deliveryNotes = _deliveryNotes.text ?? '';
      order.deliveryOrderInfo.userPhoneNumber = phoneNumber ?? '';
      order.deliveryOrderInfo.userName = _userName.text ?? '';
      // order.paymentMethod = paymentMethod;
      order.deliveryOrderInfo.deliveryLocation = userLocation;

      if(order.orderID == null || order.orderID.isEmpty){
        if(BlocProvider.of<CreateOrderBloc>(context).state is OrderCreateLoading) return;
        OrderViewModel orderViewModel = OrderViewModel.clone(order);
        if (_promoCodeViewModel.promoCodeTitle != null) {
          orderViewModel.promoCodeViewModel = PromoCodeViewModel(promoCodeTitle: _promoCodeViewModel.promoCodeTitle);
        }
        BlocProvider.of<CreateOrderBloc>(context).add(CreateDeliveryOrder(orderModel: orderViewModel, addressId: userLocation.id.toString()),);
      } else {
        if((paymentBloc.state is PaymentWithVisaReady) == false) {
          paymentBloc.add(RequestVisaPayment(paymentOrderModel: order));
        }
        else if(paymentBloc.state is PaymentWithVisaReady){
          Map<String,dynamic> requestHeaders = await NetworkUtilities.getHttpHeaders();
          flutterWebViewPlugin.launch((paymentBloc.state as PaymentWithVisaReady).paymentLink, hidden: false , headers: requestHeaders , );
          return ;
        }
      }
    } else if (userLocation == null) {
      HelperWidget.showToast(message: (LocalKeys.SELECT_DELIVERY_LOCATION).tr(), isError: true);
      return;
    } else if (phoneNumber != null && phoneNumber.isEmpty) {
      HelperWidget.showToast(message: (LocalKeys.EMPTY_PHONE_NUMBER).tr(), isError: true);
      return;
    } else if (isValidPhoneNumber.value == false) {
      HelperWidget.showToast(message: (LocalKeys.INVALID_PHONE_FORMAT).tr(), isError: true);
      return;
    }
    /// uncomment when payment methods are available
    /*else if (paymentMethod == null) {
      HelperWidget.showToast(message: (LocalKeys.SELECT_PAYMENT_METHOD).tr(), isError: true);
      return;
    }*/
  }

  void _addNewAddress() async {
    CustomerAddressViewModel customerLocation =
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddNewAddressScreen(
          restaurantViewModel: widget.restaurant,
        )));
    if (customerLocation != null) {
      if (!isAddressSupported(customerLocation, widget.restaurant.deliveryInformation.deliveryAreas)) {
        HelperWidget.showToast(
            message: tr(LocalKeys.ADDRESS_ADDED_BUT_NOT_AVAILABLE),
            isError: false
        );
      }
    }
    setState(() {});
  }

  Widget getDeliveryFooter() {
    double deliveryFees = 0.0;
    if (widget.restaurant.deliveryInformation.feesType ==
        DeliveryFeesType.AREA_BASED) {
      if (restaurantRegion != null)
        deliveryFees = restaurantRegion.deliveryCost;
      else
        deliveryFees = 0.0;
    } /*else {
      deliveryFees =
          widget.restaurant.deliveryInformation.restaurantDeliveryFees;
    }*/

    return BlocProvider.value(
      value: BlocProvider.of<CreateOrderBloc>(context),
      child: DeliveryFooter(
        feesType: widget.restaurant.deliveryInformation.feesType,
        orderNetPrice: UserCart().calculateCart(),
        delivery: deliveryFees,
        region: null,
        restaurantService: widget.restaurant.restaurantTaxes,
        restaurantCurrency: widget.restaurant.restaurantCurrency.currencyName ?? '',
        showTotal: true,
        toBeDetermined: true,
        state: BlocProvider.of<CreateOrderBloc>(context).state,
        onPressed: (code) {
          Navigator.of(context).pop();
          if (userLocation == null) {
            HelperWidget.showToast(message: tr(LocalKeys.SELECT_AREA_FIRST), isError: true);
            return;
          }
          BlocProvider.of<CreateOrderBloc>(context).add(ValidatePromoCode(
            promoCode: code,
            orderList: UserCart().getNonConfirmedItems,
            orderType: OrderType.DELIVERY,
            customerAddressId: userLocation.id.toString(),
            restaurantId: widget.restaurant.restaurantListViewModel.restaurantId.toString(),
          ));
        },
      ),
    );
  }

  bool isAddressSupported(
      CustomerAddressViewModel location, List<DeliveryArea> deliveryRegions) {
    if (widget.restaurant.deliveryInformation.feesType != DeliveryFeesType.AREA_BASED) {
      return true;
    }
    if (deliveryRegions == null || deliveryRegions.length == 0) {
      return true;
    }

    List<DeliveryArea> reducedList = deliveryRegions
        .where((element) => location.regionViewModel.regionId == element.regionId)
        .toList();
    int areaIndex = reducedList.indexWhere((element) => element.areaId == location.areaViewModel.areaId);
    if (areaIndex > -1) {
      return true;
    }
    return false;
  }

  void initScreenFields() {
    if (widget.restaurant.supportedPaymentMethods != null &&
        widget.restaurant.supportedPaymentMethods.length > 0)
      paymentMethod = widget.restaurant.supportedPaymentMethods[0];

    if (widget.restaurant.deliveryInformation.feesType ==
        DeliveryFeesType.AREA_BASED) {
      if (widget.restaurant.deliveryInformation.deliveryAreas != null &&
          widget.restaurant.deliveryInformation.deliveryAreas.length > 0) {
        restaurantRegion =
        widget.restaurant.deliveryInformation.deliveryAreas[0];
      }
    }

    if (BlocProvider.of<UserBloc>(context).user != null)
      phoneNumber = BlocProvider.of<UserBloc>(context).user.phoneNumber ?? '';

    for (int i = 0; i < widget.supportedCountriesCode.length; i++) {
      if (phoneNumber.contains(widget.supportedCountriesCode[i])) {
        isValidPhoneNumber.sink.add(true);
        phoneIsoCode = widget.supportedCountriesCode[i];
        break;
      } else {
        isValidPhoneNumber.sink.add(false);
      }
    }

  }
}
