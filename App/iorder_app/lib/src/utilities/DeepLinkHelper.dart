import 'package:ande_app/src/resources/URL.dart';
import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DynamicLinkHelper {
  static void initDynamicLinks(BuildContext context, navigatorKey) async {
    //Dynamic links
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      try {
        if (deepLink.query.contains('=')) {
          String restaurantId = deepLink.query.split('=')[1];
          navigatorKey.currentState.push(MaterialPageRoute(
              builder: (context) => RestaurantSplashScreen(
                    type: RestaurantLoadingType.DINING,
                    restaurantID: restaurantId,
                    restaurantImagePath: '',
                    restaurantName: '',
                  )));
        }
      } catch (exception) {
        debugPrint("Unable to parse deepLink => $exception");
      }
    }
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        try {
          if (deepLink.query.contains('=')) {
            String restaurantId = deepLink.query.split('=')[1];
            navigatorKey.currentState.push(MaterialPageRoute(
                builder: (context) => RestaurantSplashScreen(
                      type: RestaurantLoadingType.DINING,
                      restaurantID: restaurantId,
                      restaurantImagePath: '',
                      restaurantName: '',
                    )));
          }
        } catch (exception) {
          debugPrint("Unable to parse deepLink => $exception");
        }
      }
    }, onError: (OnLinkErrorException e) async {
      debugPrint(e.message);
    });
    //Dynamic Links
  }

  static Future<String> createRestaurantLink(String restaurantId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://ande.page.link',
      link: Uri.parse('${URL.BASE_URL}/restaurant?id=$restaurantId'),
      androidParameters: AndroidParameters(
        packageName: 'com.mobidevlabs.ande',
      ),
      // NOT ALL ARE REQUIRED ===== HERE AS AN EXAMPLE =====
      iosParameters: IosParameters(
        bundleId: 'com.mobidevlabs.ande',
        minimumVersion: '2.0.0',
        appStoreId: '1495232289',
      ),
//      googleAnalyticsParameters: GoogleAnalyticsParameters(
//        campaign: 'example-promo',
//        medium: 'social',
//        source: 'orkut',
//      ),
//      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
//        providerToken: '123456',
//        campaignToken: 'example-promo',
//      ),
//      socialMetaTagParameters: SocialMetaTagParameters(
//        title: 'Example of a Dynamic Link',
//        description: 'This link works whether app is installed or not!',
//      ),
    );
    final Uri dynamicUrl = await parameters.buildUrl();
    return dynamicUrl.toString();
  }
}
