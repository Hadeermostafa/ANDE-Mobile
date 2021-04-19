// Imports the Flutter Driver API.
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {


  group('login to the app', ()
  {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      // TestWidgetsFlutterBinding.ensureInitialized();

      final envVars = Platform.environment;
      final adbPath = join(
        envVars['ANDROID_SDK_ROOT'] ?? envVars['ANDROID_HOME'],
        'platform-tools',
        Platform.isWindows ? 'adb.exe' : 'adb',
      );
      await Process.run(adbPath, [
        'shell',
        'pm',
        'grant',
        'com.mobidevlabs.ande', // replace with your app id
        'android.permission.CAMERA'
      ]);
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
        print("testing done");
      }
    });

    test('select your country', () async {
      await Future.delayed(const Duration(seconds: 3), () {
        print('welcome to ANDE');
      });
      //   expect(find.text('Color #1'), findsNothing);
      //  print("testing done");
      //   expect(await driver.getText(counterTextFinder), "1");
      await driver.tap(find.text('Egypt'));
      await Future.delayed(const Duration(seconds: 5),);
    });

    // test('QR_SCANNER', () async{
    //   await Future.delayed(const Duration(seconds: 10),);
    //   // var stateKey = find.byValueKey("ScanBarCodeState");
    //  // await Future.delayed(const Duration(seconds: 5),);
    //   // (stateKey as ScanBarCodeState).qrCallback("qr goes here");
    //   scanBarCodeStateKey.currentState.qrCallback('http://andedev-env.eba-je3ap3sa.me-south-1.elasticbeanstalk.com/restaurants/MjE-/menu?str=eyAicmVzdGF1cmFudF9JZCI6ICAiMjEiICwgInRhYmxlX051bWJlciIgOiAiMSIgLCAibG9nb191cmwiOiAicmVzdGF1cmFudHMvMjEvbG9nby5wbmciICwgIm5hbWUiOiAiQmF6b29rYSIgfQ==');
    //   // do code here
    //   await Future.delayed(const Duration(seconds: 10),);
    // });

    test('open side menu', () async {
      var sidemenu = find.byType("IconButton");
      await driver.tap(sidemenu);
      print("side menue done");
      await Future.delayed(const Duration(seconds: 2),);
      var loginbtn = find.text("Login");
      await driver.tap(loginbtn);
      await Future.delayed(const Duration(seconds: 2),);
      print("login done");
    });


    test('login with phone number', () async {
      var phone_number = find.byValueKey("phone_number");
      await driver.tap(phone_number);

      await Future.delayed(const Duration(seconds: 10),);
      var input = find.byValueKey('inputphone');
      await driver.tap(input);
      await driver.enterText('01119076270');
      await Future.delayed(const Duration(seconds: 4),);
      print("phone number entered successfully");
      var verify = find.byValueKey('verify');
      await driver.tap(verify);
      var verification_code = find.byValueKey('code');
      await driver.tap(verification_code);
      await driver.enterText('123456');
      print("code verified successfully");
      var send_code = find.byValueKey('sendcode');
      await driver.tap(send_code);
      await Future.delayed(const Duration(seconds: 10),);
    });
  });
}
