import 'package:firebase_messaging/firebase_messaging.dart';

class FireBaseHelper {



  static void initFireBaseMessaging({Function omMessageReceived}) {
    FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(omMessageReceived);
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      omMessageReceived(event);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      omMessageReceived(event);
    });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage event) {
      omMessageReceived(event);
      return;
    });


  }

  static Future<String> getPushToken() async {

    String pushNotificationToken = await FirebaseMessaging.instance.getToken();
    return pushNotificationToken;
  }
}
