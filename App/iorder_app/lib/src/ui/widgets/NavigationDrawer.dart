import 'dart:io';

import 'package:ande_app/src/blocs/bloc/ApplicaitonDataBloc.dart';
import 'package:ande_app/src/blocs/states/UserStates.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:ande_app/src/ui/dialogs/MenuLanguageDialog.dart';
import 'package:ande_app/src/ui/screens/OrdersHistoryScreen.dart';
import 'package:ande_app/src/ui/screens/SplashScreen.dart';
import 'package:ande_app/src/ui/screens/UserCountrySelectionScreen.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart' as ll;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hidden_drawer_menu/controllers/simple_hidden_drawer_controller.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:package_info/package_info.dart';

import '../../../main.dart';
import '../../blocs/bloc/UserBloc.dart';
import '../../blocs/events/AuthenticationEvents.dart';
import '../../blocs/states/AuthenticationStates.dart';
import '../../data_providers/models/CountryModel.dart';
import '../../data_providers/models/LanguageModel.dart';
import '../../utilities/HelperFunctions.dart';
class NavigationDrawer extends StatefulWidget {
  final onLoginPressed;
  NavigationDrawer({this.onLoginPressed, this.onLangChanged});
  final Function onLangChanged;

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer>
    with SingleTickerProviderStateMixin {
  LanguageModel systemLanguage;
  CountryModel currentCountry;
  User user;

  bool isAnonymous = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    user = BlocProvider.of<UserBloc>(context).user;
    isAnonymous = Repository.isAnonymousUser(); // 'ande.anonymous@mdlabs.com';
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    initDrawerSettings();

    return BlocListener(
      listener: (context, state) {
        if (state is UserUnInitialized) {
          SimpleHiddenDrawerController.of(context).toggle();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return UserCountrySelectionScreen();
          }), (route) => false);
        }
      },
      bloc: BlocProvider.of<UserBloc>(context).authBloc,
      child: BlocConsumer(
        bloc: BlocProvider.of<UserBloc>(context),
        listener: (context, state) async {
          if (state is UserLoadingFailed) {
            if (state.error.errorCode == HttpStatus.requestTimeout) {
              HelperWidget.showNetworkErrorDialog(context);
              await Future.delayed(Duration(seconds: 2), () {});
              HelperWidget.removeNetworkErrorDialog(context);
             // BlocProvider.of<UserBloc>(context).add(state.event);
            }
          }  
        },
        builder: (context, state) {
          user = BlocProvider.of<UserBloc>(context).user;
          // isAnonymous =
          //     user.email != null && user.email == Constants.userMail;
          return ModalProgressHUD(
            progressIndicator: loadingFlare,
            inAsyncCall: state is UserLoadingState,
            child: Material(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/menu_background.jpg'),
                        fit: BoxFit.cover)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .1,
                      ),
                      getFbAnalytic(),
                      SizedBox(
                        height: 35,
                      ),
                      Text((LocalKeys.LANGUAGE_LABEL), style: TextStyle(color: Color(0xFF808080)),).tr(),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (BlocProvider.of<UserBloc>(context).userActiveOrder != null) {
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          child: Center(
                                            child: Text((LocalKeys
                                                .CHANGE_LANGUAGE_WITH_ACTIVE_ORDER_ERROR)
                                                .tr()),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                            return;
                          }
                          await showLocalePickerDialog();
                        },
                        child: Row(
                          children: <Widget>[
                            Text(systemLanguage.localeName),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: isAnonymous,
                        child: Container(height: 0.0, width: 0.0,),
                        replacement: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> OrdersHistoryScreen()));
                                  SimpleHiddenDrawerController.of(context)
                                      .toggle();
                                },
                                child: Padding(
                                  padding: EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0, end: 16.0),
                                  child: Text(
                                    (LocalKeys.HISTORY).tr(),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text((LocalKeys.COUNTRY_LABEL), style: TextStyle(color: Color(0xFF808080)),).tr(),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {

                          if (BlocProvider.of<UserBloc>(context).userActiveOrder != null) {
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          child: Center(
                                            child: Text((LocalKeys
                                                .CHANGE_COUNTRY_WITH_ACTIVE_ORDER_ERROR)
                                                .tr()),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                            return;
                          }
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      UserCountrySelectionScreen()));
                        },
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              child: Material(
                                elevation: 5,
                                child: AndeImageNetwork(
                                  currentCountry.countryIconImagePath,
                                  constrained: true,
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(currentCountry.countryName),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: isAnonymous,
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    widget.onLoginPressed();
                                    SimpleHiddenDrawerController.of(context)
                                        .toggle();
                                  },
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(top: 35.0, bottom: 35.0, end: 16.0),
                                    child: Text(
                                      (LocalKeys.LOGIN).tr(),
                                      key: Key("loginbtn"),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              ),
                              getPackageInfo(),
                            ],
                          ),
                        ),
                        replacement: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (BlocProvider.of<UserBloc>(context).userActiveOrder != null) {
                                      showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    child: Center(
                                                      child: Text((LocalKeys
                                                          .LOGOUT_WHILE_HAVE_ACTIVE_ORDER_ERROR)
                                                          .tr()),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                      return;
                                    }
                                    BlocProvider.of<UserBloc>(context)
                                        .authBloc
                                        .add(Logout());
                                  },
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(top: 35.0, bottom: 35.0, end: 16.0),
                                    child: Text(
                                      (LocalKeys.LOGOUT).tr(),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              ),
                              getPackageInfo(),
                            ],
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
      ),
    );
  }

  getFbAnalytic() {
    if (isAnonymous) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            (LocalKeys.ANONYMOUS_USER).tr(),
            textAlign: TextAlign.start,
            style: TextStyle(color: Color(0xFF808080)),
          ),
        ],
      );
    }
    if (user.phoneNumber != null && user.phoneNumber.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            (LocalKeys.USER_PHONE).tr(),
            textAlign: TextAlign.start,
            style: TextStyle(color: Color(0xFF808080)),
          ),
          Text(
            '${user.phoneNumber}',
            textAlign: TextAlign.start,
          ),
        ],
      );
    } else if (user.email != null && user.email.length > 0) {
      Size txtSize = _textSize(user.email, TextStyle());
      String userEmail = '';
      if (txtSize.width > (MediaQuery.of(context).size.width / 2)) {
        List<String> splitEmail = user.email.split('@');
        for (int i = 0; i < splitEmail.length; i++) {
          userEmail += splitEmail[i];
          if (i < splitEmail.length - 1) {
            userEmail += '\n@';
          }
        }
      } else {
        userEmail = user.email;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            (LocalKeys.USER_MAIL).tr(),
            textAlign: TextAlign.start,
            style: TextStyle(color: Color(0xFF808080)),
          ),
          Text(
            '$userEmail',
            textAlign: TextAlign.start,
          ),
        ],
      );
    } else if (user.displayName != null && user.displayName.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            (LocalKeys.USERNAME).tr(),
            textAlign: TextAlign.start,
            style: TextStyle(color: Color(0xFF808080)),
          ),
          Text(
            '${user.displayName}',
            textAlign: TextAlign.start,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            (LocalKeys.ANONYMOUS_USER).tr(),
            textAlign: TextAlign.start,
            style: TextStyle(color: Color(0xFF808080)),
          ),
        ],
      );
    }
  }

  showLocalePickerDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: MenuAvailableLanguageDialog(
              title: (LocalKeys.APP_SUPPORTED_LANGUAGES).tr(),
              restaurantLanguages: LanguageHelper.getSystemLanguages(),
              onLanguageSelected: (LanguageModel language){
                systemLanguage = language;
                ll.EasyLocalization.of(context).locale =
                (Locale(systemLanguage.localeCode));
                if (widget.onLangChanged != null) {
                  widget.onLangChanged(systemLanguage.localeCode);
                }
                Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(
                        builder: (context) => SplashScreen(GlobalKey<NavigatorState>())), (route) => false);
              },
              preSelectedLang: systemLanguage,
            )
          );
        });
  }


  void initDrawerSettings() {

    try {
      currentCountry = BlocProvider.of<ApplicationDataBloc>(context)
          .supportedCountries
          .where((element) =>
      element.countryId ==
          BlocProvider.of<UserBloc>(context)
              .userCountry.countryId)
          .toList()[0];
    } catch (exception) {
      currentCountry = CountryModel(
          countryName: 'Egypt',
          countryId: '1',
          countryDialCode: '+20',
          countryIconImagePath: '');
    }
    user = BlocProvider.of<UserBloc>(context).user;
    systemLanguage = LanguageHelper.getLangModelFromLocaleCode(
        ll.EasyLocalization.of(context).locale.languageCode);
  }

  Widget getPackageInfo() {
    String version = "", buildNumber = "";
    PackageInfo packageInfo = BlocProvider.of<ApplicationDataBloc>(context).appInfo;
    if(packageInfo != null){
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    }
    return Text('v$version-B$buildNumber',
      style: TextStyle(color: Colors.grey[400], fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
