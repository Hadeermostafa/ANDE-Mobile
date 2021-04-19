import 'dart:convert';
import 'dart:io';

import 'package:ande_app/main.dart';
import 'package:ande_app/src/blocs/bloc/LoginBloc.dart';
import 'package:ande_app/src/blocs/events/LoginEvents.dart';
import 'package:ande_app/src/blocs/states/LoginStates.dart';
import 'package:ande_app/src/data_providers/models/OrderViewModel.dart';
import 'package:ande_app/src/resources/Resources.dart';
import 'package:ande_app/src/ui/dialogs/PhoneAuthenticationDialog.dart';
import 'package:ande_app/src/ui/screens/LandingScreen.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/NavigationDrawer.dart';
import 'package:ande_app/src/utilities/FirebaseHelper.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:easy_localization/easy_localization.dart' as ll;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/animated_drawer_content.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/simple_hidden_drawer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../blocs/bloc/UserBloc.dart';
import '../../../blocs/bloc/VoucherBloc.dart';
import '../../../resources/Constants.dart';
import '../../../resources/UserCart.dart';
import '../RestaurantSplashScreen.dart';
import 'AndeDineInPaymentScreen.dart';


Key scanBarCodeStateKey = Key('_ScanBarCodeState');

class AndeScanBarCodeScreen extends StatefulWidget {
  final OrderViewModel activeOrderViewModel;

  AndeScanBarCodeScreen({this.activeOrderViewModel});

  @override
  ScanBarCodeState createState() => ScanBarCodeState();
}

class ScanBarCodeState extends State<AndeScanBarCodeScreen> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  UserBloc userDataBloc;
  LoginBloc _loginBloc;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController qrCameraController;


  bool qrScanned = false;
  final bgColor = Color.fromARGB(100, 252, 252, 252);
  final whiteColor = Colors.white;
  final BoxShadow boxShadow = BoxShadow(
    spreadRadius: 0,
    blurRadius: 10,
    color: Colors.black45.withOpacity(.2),
  );

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(
        authenticationBloc: BlocProvider.of<UserBloc>(context).authBloc);
  }

  bool drawerOpened = false;

  @override
  Widget build(BuildContext context) {


    FireBaseHelper.getPushToken().then((value) => print("FCM -> $value"));

    _requestOrCheckCamera();
    userDataBloc = BlocProvider.of<UserBloc>(context);
    return WillPopScope(
      key: scanBarCodeStateKey,
      onWillPop: () async => false,
      child: Container(
        color: Colors.white,
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: SimpleHiddenDrawer(
          typeOpen: Constants.currentAppLocale == "en"
              ? TypeOpen.FROM_LEFT
              : TypeOpen.FROM_RIGHT,
          verticalScalePercent: 90,
          slidePercent: 75,
          isDraggable: true,
          menu: NavigationDrawer(onLoginPressed: () {
            showBottomSheet();
          }, onLangChanged: (String newLocale) {
            ll.EasyLocalization.of(context).locale = (Locale(newLocale));
            userDataBloc.languageChangeNotifier.add(true);
            return;
          }),
          screenSelectedBuilder: (position, controller) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              key: _scaffoldKey,
              appBar: AndeAppbar(
                screenTitle: (LocalKeys.APPLICATION_NAME).tr(),
                leading :IconButton(
                    icon: ImageIcon(
                      AssetImage(Resources.drawerMenuIcon),
                      key: Key('sidemenu'),
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller.toggle();
                    }),
              ),
              body: getScreenBody(),
            );
          },
        ),
      ),
    );
  }

  getScreenBody() {
    return BlocListener(
      bloc: _loginBloc,
      listener: (context, state) async{
        if (state is LoginSuccess) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingScreen(pageIndex: 0,)));
        } else if (state is LoginError) {
          if (state.error.errorCode == HttpStatus.requestTimeout) {
            HelperWidget.showNetworkErrorDialog(context);
            await Future.delayed(Duration(seconds: 2), () {});
            HelperWidget.removeNetworkErrorDialog(context);
          } else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
            HelperWidget.showToast(
                message: (LocalKeys.SERVER_UNREACHABLE).tr(),
                isError: true);
          } else if (state.error.errorCode != 401) {
            HelperWidget.showToast(
                message: state.error.errorMessage ?? '',
                isError: true
            );
          }
        }
      },
      child: BlocConsumer(
        bloc: userDataBloc,
        listener: (context, state) {},
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              getSectionHeader(LocalKeys.SCAN_QR_BUTTON_LABEL),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    boxShadow: [
                      boxShadow,
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height : MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                            color: whiteColor,
                            //  color: Colors.white,
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/scan_camera_border.png',
                                ),
                                fit: BoxFit.fill)),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: FutureBuilder<bool>(
                            future: _requestOrCheckCamera(),
                            builder: (context, snapshot) {
                              return snapshot == null ||
                                      snapshot.data == null
                                  ? Center(
                                      child: Center(
                                        child: SizedBox(
                                          width: 25,
                                          height: 25,
                                          child:
                                              CircularProgressIndicator(),
                                        ),
                                      ),
                                    )
                                  : (snapshot.data ??
                                          false || !qrScanned)
                                      ? QRView(
                                          key: qrKey,
                                          onQRViewCreated: _onQRViewCreated,
                                        )
                                      : Container(
                                          child: Center(
                                            child: Text(
                                              (LocalKeys
                                                      .CAMERA_PERMISSION_DENIED)
                                                  .tr(),
                                              textAlign:
                                                  TextAlign.center,
                                              textScaleFactor: 1,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                              maxLines: 3,
                                            ),
                                          ),
                                        );
                            },
                          ),
                        ),
                      ),
                      HelperWidget.verticalSpacer(heightVal: 5.0),
                      Text(
                        (LocalKeys.SCAN_QR_DESCRIPTION).tr(),
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          //  fontFamily: Constants.FONT_ARIAL,
                          color: Colors.black.withOpacity(0.5),
                          //fontWeight: FontWeight.w600,
                        ),
                      ),
                      HelperWidget.verticalSpacer(heightVal: 13.0),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getSectionHeader(String headerKeyName) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Text(
          (headerKeyName).tr(),
          textScaleFactor: 1,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }


  Future<bool> _requestOrCheckCamera() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isUndetermined) {
      status = await Permission.camera.request();
      isCameraEnabled = status.isGranted;
    }
    isCameraEnabled = status.isGranted;
    return isCameraEnabled;
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
                          key: Key('facebook'),
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
                            key: Key('phone_number')  ,
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

  void qrCallback(String code) async {
    if (qrScanned || !ModalRoute
        .of(context)
        .isCurrent) {
      return;
    }


    final split = code.split('str=');
    final Map<int, String> values = {
      for (int i = 0; i < split.length; i++)
        i: split[i]
    };
    var decoded = utf8.decode(base64.decode(values[1]));
    var codeMap = json.decode(decoded);
    String restaurantId = codeMap['restaurant_Id'] ?? '';
    String tableNum = codeMap['table_Number'] ?? '';
    String restaurantLogo = codeMap['logo_url'] ?? '';
    String restaurantName = codeMap['name'];
    FirebaseAnalytics().logEvent(name: "SCAN_QR", parameters: {
      "restaurantId" : restaurantId,
      "restaurantName" : restaurantName ,
      "table_Number" : tableNum ,
    });

    UserCart().orderTableNumber = tableNum;
    if (!qrScanned && tableNum.isNotEmpty && restaurantLogo.isNotEmpty ) {
      qrScanned = true;
      if (widget.activeOrderViewModel != null) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return BlocProvider.value(
                value: VoucherBloc(),
                child: AndeDineInPaymentScreen(
                  comingFromActive: true,
                  userOrderModel: widget.activeOrderViewModel,
                ),
              );
            },
          ),);

        qrScanned = false;
        setState(() {});
      } else {
        await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
          return BlocProvider.value(
            value: VoucherBloc(),
            child: RestaurantSplashScreen(
              type: RestaurantLoadingType.DINING,
              restaurantID: restaurantId,
              restaurantImagePath: restaurantLogo,
              restaurantName: restaurantName,
            ),
          );
        }));
        qrCameraController.resumeCamera();
        qrScanned = false;

      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      qrCameraController = controller;
      qrCallback(scanData.code);
    });
  }
}