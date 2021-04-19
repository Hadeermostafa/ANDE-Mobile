

import 'dart:io';

import 'package:ande_app/src/blocs/bloc/LoginBloc.dart';
import 'package:ande_app/src/blocs/bloc/UserBloc.dart';
import 'package:ande_app/src/blocs/events/LoginEvents.dart';
import 'package:ande_app/src/blocs/states/LoginStates.dart';
import 'package:ande_app/src/data_providers/models/RestaurantListViewModel.dart';
import 'package:ande_app/src/resources/Resources.dart';
import 'package:ande_app/src/ui/dialogs/PhoneAuthenticationDialog.dart';
import 'package:ande_app/src/ui/screens/LandingScreen.dart';
import 'package:ande_app/src/ui/screens/delivery_screens/RestaurantSplashScreenDelivery.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/ListViewAnimatorWidget.dart';
import 'package:ande_app/src/ui/widgets/NavigationDrawer.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/animated_drawer_content.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/simple_hidden_drawer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../../../main.dart';
import '../../../blocs/bloc/RestaurantListingBloc.dart';
import '../../../blocs/events/RestaurantListingEvents.dart';
import '../../../blocs/states/RestaurantListingStates.dart';
import '../../../resources/Constants.dart';
import '../../list_tiles/RestaurantTile.dart';

class RestaurantsListScreen extends StatefulWidget {
  @override
  _RestaurantsListState createState() => _RestaurantsListState();
}

class _RestaurantsListState extends State<RestaurantsListScreen> {

  RestaurantListBloc _restaurantListBloc;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();
  LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    String countryId = BlocProvider.of<UserBloc>(context).userCountry.countryId;
    _restaurantListBloc = RestaurantListBloc(countryId);
    _restaurantListBloc.add(LoadRestaurants());
    _scrollController.addListener(onScrollListener);
    _loginBloc = LoginBloc(
        authenticationBloc: BlocProvider.of<UserBloc>(context).authBloc);
  }



  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: SimpleHiddenDrawer(
        typeOpen: Constants.currentAppLocale == "en"
            ? TypeOpen.FROM_LEFT
            : TypeOpen.FROM_RIGHT,
        verticalScalePercent: 90,
        slidePercent: 75,
        isDraggable: true,
        menu: NavigationDrawer(
          onLoginPressed: () {
            showBottomSheet();
          },
            onLangChanged: (String newLocale) {
          EasyLocalization.of(context).locale = (Locale(newLocale));
          setState(() {});
          BlocProvider.of<UserBloc>(context).languageChangeNotifier.add(true);
          _restaurantListBloc.add(LoadRestaurants());
        }),
        screenSelectedBuilder: (position, controller) {
          return Container(
            child: BlocListener(
              bloc: _loginBloc,
              listener: (context, state) async {
                if (state is LoginSuccess) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LandingScreen(pageIndex: 1,)));
                } else if (state is LoginError) {
                  if (state.error.errorCode == HttpStatus.requestTimeout) {
                    HelperWidget.showNetworkErrorDialog(context);
                    await Future.delayed(Duration(seconds: 2), () {});
                    HelperWidget.removeNetworkErrorDialog(context);
                  } else
                  if (state.error.errorCode == HttpStatus.serviceUnavailable) {
                    HelperWidget.showToast(
                        message: (LocalKeys.SERVER_UNREACHABLE).tr(),
                        isError: true)
                    ;
                  } else if (state.error.errorCode != 401) {
                    HelperWidget.showToast(
                        message: state.error.errorMessage ?? '',
                        isError: true
                    );
                  }
                }
              },
              child: BlocConsumer(
                bloc: _restaurantListBloc,
                listener: (context, state) async{
                  if (state is RestaurantsLoadingFailed) {
                    // HelperWidget.showToast(message: (LocalKeys.COMING_SOON).tr(), isError: false);
                    if (state.error.errorCode == HttpStatus.requestTimeout) {
                      HelperWidget.showNetworkErrorDialog(context);
                      await Future.delayed(Duration(seconds: 2), () {});
                      HelperWidget.removeNetworkErrorDialog(context);
                      resolveNeedRedispatch(state.event);
                      return;
                    }
                    else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
                      HelperWidget.showToast(message: (LocalKeys.SERVER_UNREACHABLE).tr(), isError: true);
                    }
                    else {
                      HelperWidget.showToast(message: state.error.errorMessage ?? '' , isError: true);
                    }
                  }
                },
                builder: (context , state){
                  return Scaffold(
                    backgroundColor: Color(0xfffcfcfb),
                    appBar: AndeAppbar(
                      screenTitle:  (LocalKeys.RESTAURANT_LISTING_SCREEN_TITLE).tr(),
                      leading: IconButton(icon: ImageIcon(AssetImage(Resources.drawerMenuIcon), color: Colors.white,),
                          onPressed: () {
                            controller.toggle();
                          }),
                      hasBackButton: false ,
                    ),
                    key: _scaffoldKey,
                    body: ModalProgressHUD(
                      progressIndicator: loadingFlare,
                      inAsyncCall: state is RestaurantsLoading,
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 20 , bottom: 20 , left: 10 , right: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Color(0xff707070).withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [BoxShadow(
                                      color: Color(0xffF2F2F2),
                                      blurRadius: 5.0,
                                      spreadRadius: 3
                                    ),]
                                ),
                                child: TextField(
                                  onChanged: (searchKey) {
                                    _restaurantListBloc.add(SearchRestaurant(queryText: searchKey));
                                    return;
                                  },
                                  decoration: InputDecoration(
                                    fillColor: Color(0xffffffff),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:  Color(0xfff1f1),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Color(0xFFE0E0E0),
                                    ),
                                    hintText: (LocalKeys.SEARCH_RESTAURANT_HINT).tr(),
                                    hintStyle: TextStyle(color: Color(0xFFb2b2b2)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),

                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: StreamBuilder<List<RestaurantListViewModel>>(
                                  stream: _restaurantListBloc.restaurantsStream,
                                  builder: (context, snapShot) {
                                    if (snapShot.hasData) {
                                      return (snapShot.data.length == 0)  ?
                                      emptyResultView() : restaurantsListing(snapShot.data);
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _restaurantListBloc.dispose();
    super.dispose();
  }



  Widget emptyResultView() {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.announcement),
        Text((LocalKeys.NO_DATA_AVAILABLE).tr())
      ],
    );
  }
  Widget restaurantsListing(List<RestaurantListViewModel> data) {
    return ListViewAnimatorWidget(
      scrollController: _scrollController,
      isScrollEnabled: true,
      listChildrenWidgets: data.map((RestaurantListViewModel restaurantListViewModel) => RestaurantTile(
        onRestaurantTap: () {
          navigateToRestaurant(restaurantListViewModel);
          return;
        },
        dataModel: restaurantListViewModel,
      )).toList(),
    );
  }



  void navigateToRestaurant(RestaurantListViewModel listingRestaurantModel) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RestaurantSplashScreenDelivery(
        restaurantListViewModel : listingRestaurantModel
      );
    }));
  }
  void resolveNeedRedispatch(RestaurantsListingEvents event) {
    _restaurantListBloc.add(event);
  }

  void onScrollListener() {
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels < 50) {
      if ((_restaurantListBloc.state is RestaurantsLoading) == false && _restaurantListBloc.reachedEnd == false) {
        _restaurantListBloc.add(LoadRestaurants());
      }
    }
  }

  void showBottomSheet() async{


    bool appleLoginAvailable = await AppleSignIn.isAvailable() ;
    appleLoginAvailable = appleLoginAvailable && Platform.isIOS;

    _scaffoldKey.currentState.showBottomSheet<Null>((context) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
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
                  Visibility(
                    replacement: Container(width: 0, height: 0,),
                    visible: appleLoginAvailable,
                    child: Container(
                      width: 70,
                      height: 70,
                      child: FlatButton.icon(
                        onPressed: () {
                          _loginBloc
                              .add(PerformLogin(loginMethod: LoginMethods.APPLE));
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          MdiIcons.apple,
                          color: Colors.grey,
                        ),
                        label: Text(''),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void loginWithPhoneDialog() async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return PhoneAuthenticationDialog(
            loginBloc: _loginBloc,
          );
        });
    _loginBloc.phoneUser.sink.add(null);
  }
}
