import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:ande_app/src/ui/dialogs/NetworkErrorView.dart';
import 'package:ande_app/src/utilities/BlocLoggerDelegate.dart';
import 'package:ande_app/src/utilities/FirebaseAnalyticsObserver.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flare_flutter/asset_provider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/blocs/bloc/ApplicaitonDataBloc.dart';
import 'src/blocs/bloc/AuthenticationBloc.dart';
import 'src/blocs/bloc/NotificationBloc.dart';
import 'src/blocs/bloc/UserBloc.dart';
import 'src/resources/Constants.dart';
import 'src/ui/screens/SplashScreen.dart';
import 'src/utilities/FirebaseHelper.dart';

final NotificationBloc _notificationBloc = NotificationBloc();
final UserBloc userBloc = UserBloc(AuthenticationBloc());
final ApplicationDataBloc appBloc = ApplicationDataBloc();


Future<dynamic> onBackgroundMessage(message) {
   Firebase.initializeApp().then((value){
     if (_notificationBloc != null)
       _notificationBloc.add(OnNotificationReceived(notification: message));
   });
   return null;
}

Future<dynamic> onForegroundMessage(message) {
  Firebase.initializeApp().then((value){
    if (_notificationBloc != null)
      _notificationBloc.add(OnNotificationReceived(notification: message));
  });
  return null;
}

bool isCameraEnabled = true;
Widget loadingFlare = SizedBox(
  height: 100,
  width: 100,
  child: Center(
    child: FlareActor.asset(loadingFlareProvider,
        alignment: Alignment.center,
        fit: BoxFit.contain,
        animation: "progressBar"),
  ),
);

final AssetProvider loadingFlareProvider = AssetFlare(bundle: rootBundle, name: "assets/flr/progress bar.flr");
final AssetProvider callWaiterBackgroundFlareProvider = AssetFlare(bundle: rootBundle, name: "assets/flr/call_waiter_bg.flr");
final AssetProvider callWaiterFlareProvider = AssetFlare(bundle: rootBundle, name: "assets/flr/call_waiter_flr.flr");
final OverlayEntry networkError = OverlayEntry(
    opaque: false,
    maintainState: false,
    builder: (context) => NetworkErrorView()
);


Future<void> _warmUpAnimations() async {
  await cachedActor(loadingFlareProvider);
  await cachedActor(callWaiterBackgroundFlareProvider);
  await cachedActor(callWaiterFlareProvider);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _warmUpAnimations();
  FlareCache.doesPrune = false ;
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  BlocSupervisor.delegate = BlocLoggerDelegate();



  runZoned<Future<void>>(() async {},
      onError: FirebaseCrashlytics.instance.recordError);
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);
  PermissionStatus status = await Permission.camera.status;
  if (status.isUndetermined) {
    status = await Permission.camera.request();
    isCameraEnabled = status.isGranted;
  }
  isCameraEnabled = status.isGranted;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  ));
  FireBaseHelper.initFireBaseMessaging(
    omMessageReceived: onForegroundMessage,
  );
  runApp(

    DefaultAssetBundle(bundle: TestAssetBundle(), child: EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ar')],
        path: 'assets/locale',
        useOnlyLangCode: true,
        fallbackLocale: Locale('en', 'US'),
        child: BlocProvider(
            create: (context) => _notificationBloc,
            child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/background.jpg')),
                ),
                child: MyApp()))),));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

  }

  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {

    Constants.currentAppLocale = EasyLocalization.of(context).locale.languageCode;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: userBloc),
        BlocProvider.value(value: _notificationBloc),
        BlocProvider.value(value: appBloc),
      ],
      child: MaterialApp(

        navigatorKey: navigatorKey,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
        ],
        theme: ThemeData(
            fontFamily: context.locale == null ||
                    context.locale.languageCode == null ||
                    context.locale.languageCode == "en"
                ? Constants.FONT_MONTSERRAT
                : Constants.FONT_Droid_Arabic_Kufi,
            primaryColor: Colors.white,
            accentColor: Colors.red),
        debugShowCheckedModeBanner: false,
        title: 'ANDE',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: SplashScreen(navigatorKey),
      ),
    );
  }
}

Widget buildError(BuildContext context, FlutterErrorDetails errorDetails) {
  return Scaffold(
    body: Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.warning,
              size: 50,
              color: Colors.red[800],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                LocalKeys.SOMETHING_WENT_WRONG,
                textAlign: TextAlign.center,
                textScaleFactor: 1,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ).tr(),
            ),
          ],
        ),
      ),
    ),
  );
}
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final ByteData data = await load(key);
    if (data == null) throw FlutterError('Unable to load asset');
    return utf8.decode(data.buffer.asUint8List());
  }

  @override
  Future<ByteData> load(String key) async => rootBundle.load(key);
}