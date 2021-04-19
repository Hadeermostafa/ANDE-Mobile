import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';


typedef String ScreenNameExtractor(RouteSettings settings);

String defaultNameExtractor(RouteSettings settings) => settings.name;
class FirebaseAnalyticsObserver extends RouteObserver<PageRoute<dynamic>> {
  FirebaseAnalyticsObserver({
    @required this.analytics,
    this.nameExtractor = defaultNameExtractor,
    Function(PlatformException error) onError,
  }) : _onError = onError;

  final FirebaseAnalytics analytics;
  final ScreenNameExtractor nameExtractor;
  final void Function(PlatformException error) _onError;

  void _sendScreenView(PageRoute<dynamic> route) {

    final String screenName = nameExtractor(route.settings);
    if (screenName != null) {
      analytics.setCurrentScreen(screenName: screenName).catchError(
            (Object error) {
          if (_onError == null) {
            debugPrint('$FirebaseAnalyticsObserver: $error');
          } else {
            _onError(error);
          }
        },
        test: (Object error) => error is PlatformException,
      );
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);

      try{
        analytics.logEvent(name: 'SCREEN_TRANSITION' , parameters: {
          'FROM' : previousRoute != null ? previousRoute.settings != null ? previousRoute.settings.name: 'UN-NAMED-ROUTE' : '',
          'TO' : route != null ? route.settings != null ? route.settings.name: 'UN-NAMED-ROUTE' : '',
        });
      } catch(_){}
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
      try{
        analytics.logEvent(name: 'SCREEN_TRANSITION' , parameters: {
          'FROM' : oldRoute != null ? oldRoute.settings != null ? oldRoute.settings.name: 'UN-NAMED-ROUTE' : '',
          'TO' : newRoute != null ? newRoute.settings != null ? newRoute.settings.name: 'UN-NAMED-ROUTE' : '',
        });
      } catch(_){}
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
