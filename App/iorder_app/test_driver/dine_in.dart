// Imports the Flutter Driver API.
import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';


void main() {
  group('Dine_in module', () {

    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
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
      await driver.tap(find.text('Egypt'));
      await Future.delayed(const Duration(seconds: 2),);
    });


    test('open side menu', () async {
      var sidemenu = find.byType("IconButton");
      await driver.tap(sidemenu);
      print("side menue done");
      await Future.delayed(
        const Duration(seconds: 2),
      );
      var loginbtn = find.text("Login");
      await driver.tap(loginbtn);
      await Future.delayed(
        const Duration(seconds: 2),
      );
      print("login done");
    });

    test('login with facebook', () async {
      var facebook = find.byValueKey('facebook');
      await driver.tap(facebook);
      await Future.delayed(const Duration(seconds: 15),);

    });

    test('scaning QR code', () async {
      await Future.delayed(const Duration(seconds: 20), () {
        print('scanning QR code done ');
      });
    });


    test('select items to order', () async {
      //select category from menu
      var category = find.text('Bazooka Chicken Sandwiches');
      await driver.tap(category);
      await Future.delayed(const Duration(seconds: 10),);
      //select item from menu
      var select_item = find.byValueKey('Chicken Ranch');
      await driver.tap(select_item);
      await Future.delayed(const Duration(seconds: 5),);

      // add new item
      for (int i = 1; i <= 2; i++) {
        var add_item = find.byValueKey('add item');
        await driver.tap(add_item);
        await Future.delayed(const Duration(seconds: 3),);
      }

      // scroll at the screen
      await driver.scroll(find.byValueKey('item wedgit'), 0 , -450.0, Duration(seconds: 2));
      // selecting size for the item
      var select_size = find.byValueKey('Triple');
      await driver.tap(select_size);
      await Future.delayed(const Duration(seconds: 5),);
      // selecting extras for the item
      var select_Extras_1 = find.byValueKey('Mushroom');
      await driver.tap(select_Extras_1);
      await Future.delayed(const Duration(seconds: 3),);
      var select_Extras_2 = find.byValueKey('Chili');
      await driver.tap(select_Extras_2);
      await Future.delayed(const Duration(seconds: 3),);
      // adding note for order
      var note = find.byValueKey('note');
      await driver.tap(note);
      await driver.enterText('extra cheese');
      await Future.delayed(const Duration(seconds: 5),);
      var confirm = find.byValueKey('confirm');
      await driver.tap(confirm);
    });

    test('confirming order', () async {
      var confirm_order = find.byValueKey('confirm order');
      await driver.tap(confirm_order);
      await Future.delayed(const Duration(seconds: 10),);

    });



    test('Edit items at the cart', () async {
      var editbtn = find.text('Edit');
      await driver.tap(editbtn);
      await Future.delayed(const Duration(seconds: 5),);

      var confirm = find.text('Confirm');
      await driver.tap(confirm);
      await Future.delayed(const Duration(seconds: 5),);


      var delete_item = find.byValueKey('delete');
      await driver.tap(delete_item);
      await Future.delayed(const Duration(seconds: 3),);

    //  await driver.scroll(find.byValueKey('edit items'), 0 , -300.0, Duration(seconds: 2));

      // selecting extras for the item
      var select_Extras_1 = find.byValueKey('Ranch');
      await driver.tap(select_Extras_1);
      await Future.delayed(const Duration(seconds: 3),);
      var select_Extras_2 = find.byValueKey('Cheese');
      await driver.tap(select_Extras_2);
      await Future.delayed(const Duration(seconds: 3),);

      var note = find.byValueKey('note');
      await driver.tap(note);
      await driver.enterText('Edit done successfully');
      await Future.delayed(const Duration(seconds: 3),);

      var save = find.text('Save');
      await driver.tap(save);
      await Future.delayed(const Duration(seconds: 3),);

    });

    test('confirm orders at the cart', () async {
      await Future.delayed(const Duration(seconds: 5),);
      var confirm_order = find.text('Confirm');
      await driver.tap(confirm_order);
      await Future.delayed(const Duration(seconds: 8),);

    });


    test('update order', () async {
      await Future.delayed(const Duration(seconds: 3),);
      var order_details = find.text('Order details');
      await driver.tap(order_details);

      await Future.delayed(const Duration(seconds: 5),);
      var add = find.byValueKey('add');
      await driver.tap(add);

      var category = find.text('Bazooka Chicken Sandwiches');
      await driver.tap(category);
      await Future.delayed(const Duration(seconds: 10),);
      //select item from menu
      var select_item = find.byValueKey('Chicken Ranch');
      await driver.tap(select_item);
      await Future.delayed(const Duration(seconds: 5),);

      // scroll at the screen
      await driver.scroll(find.byValueKey('item wedgit'), 0 , -450.0, Duration(seconds: 2));
      // selecting size for the item
      var select_size = find.byValueKey('Double');
      await driver.tap(select_size);
      await Future.delayed(const Duration(seconds: 5),);
      // selecting extras for the item
      var select_Extras_1 = find.byValueKey('Mushroom');
      await driver.tap(select_Extras_1);
      await Future.delayed(const Duration(seconds: 3),);
      var select_Extras_2 = find.byValueKey('Chili');
      await driver.tap(select_Extras_2);
      await Future.delayed(const Duration(seconds: 3),);
      // adding note for order
      var note = find.byValueKey('note');
      await driver.tap(note);
      await driver.enterText('Updating order done successfully');
      await Future.delayed(const Duration(seconds: 5),);
      var confirm = find.byValueKey('confirm');
      await driver.tap(confirm);

      var cart = find.byValueKey('confirm order');
      await driver.tap(cart);
      await Future.delayed(const Duration(seconds: 3),);


    });

    test('confirming update', () async {
      var confirm_order = find.text('Confirm');
      await driver.tap(confirm_order);
      await Future.delayed(const Duration(seconds: 3),);

    });

    test('call waiter', () async {
      await Future.delayed(const Duration(seconds: 6),);
      var call_waiter = find.text('Call the waiter');
      await driver.tap(call_waiter);
      await Future.delayed(const Duration(seconds: 5),);
      var close = find.byValueKey('close');
      await driver.tap(close);
      await Future.delayed(const Duration(seconds: 5),);

    });

    test('pay', () async {
      var pay_btn = find.text('Pay');
      await driver.tap(pay_btn);
      await Future.delayed(const Duration(seconds: 3),);
      var cash = find.text('Cash');
      await driver.tap(cash);
      await Future.delayed(const Duration(seconds: 8),);

    });


    });



}
