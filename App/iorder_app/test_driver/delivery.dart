// Imports the Flutter Driver API.
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('Delivery module', () {

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


    test('selecting restaurant on delivery', () async {
      await Future.delayed(
        const Duration(seconds: 3),
      );
      var delivery = find.byValueKey('delivery');
      await driver.tap(delivery);
      await Future.delayed(const Duration(seconds: 10),);
      var select_restaurant = find.byValueKey('Bazooka testing');
      await driver.tap(select_restaurant);
      await Future.delayed(const Duration(seconds: 15),);
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

      await driver.scroll(find.byValueKey('edit items'), 0 , -300.0, Duration(seconds: 2));

      // selecting extras for the item
      var select_Extras_1 = find.byValueKey('Ranch');
      await driver.tap(select_Extras_1);
      await Future.delayed(const Duration(seconds: 3),);
      var select_Extras_2 = find.byValueKey('Cheese');
      await driver.tap(select_Extras_2);
      await Future.delayed(const Duration(seconds: 3),);

      var note = find.byValueKey('note');
      await driver.tap(note);
      await driver.enterText('edit done successfully');
      await Future.delayed(const Duration(seconds: 3),);

      var save = find.text('Save');
      await driver.tap(save);
      await Future.delayed(const Duration(seconds: 3),);
      
    });

    test('confirm orders at the cart', () async {
      await Future.delayed(const Duration(seconds: 5),);
      var confirm_order = find.byValueKey('your cart');
      await driver.tap(confirm_order);
      await Future.delayed(const Duration(seconds: 10),);

    });


    test('delivery address', () async {
      var name = find.byValueKey('name');
      await driver.tap(name);
      await driver.enterText('Hadeer mostafa');
      await Future.delayed(const Duration(seconds: 3),);

      var phone = find.byValueKey('phone');
      await driver.tap(phone);
      await driver.enterText('01111111111');
      await Future.delayed(const Duration(seconds: 3),);

      var address = find.text('Add new one');
      await driver.tap(address);
      await Future.delayed(const Duration(seconds: 3),);

      var government = find.text("Choose your government");
      await driver.tap(government);
      await Future.delayed(const Duration(seconds: 3),);

      var select_government = find.text('Cairo');
      await driver.tap(select_government);
      await Future.delayed(const Duration(seconds: 3),);


      var area = find.text("Choose your area");
      await driver.tap(area);
      await Future.delayed(const Duration(seconds: 3),);

      var select_area = find.text('Madinet Nasr');
      await driver.tap(select_area);
      await Future.delayed(const Duration(seconds: 3),);

      var street = find.byValueKey("street");
      await driver.tap(street);
      await driver.enterText('Hadayq el-Qoubaa');
      await Future.delayed(const Duration(seconds: 3),);

      var building = find.byValueKey('building');
      await driver.tap(building);
      await driver.enterText('6');
      await Future.delayed(const Duration(seconds: 3),);

      var floor = find.byValueKey('floor');
      await driver.tap(floor);
      await driver.enterText('6');
      await Future.delayed(const Duration(seconds: 3),);

      await driver.scroll(find.byValueKey('address widget'), 0 , -200.0, Duration(seconds: 2));

      var flat = find.byValueKey('flat');
      await driver.tap(flat);
      await driver.enterText('6');
      await Future.delayed(const Duration(seconds: 3),);

      var additional_address = find.byValueKey('address');
      await driver.tap(additional_address);
      await driver.enterText('Next kher-zaman market');
      await Future.delayed(const Duration(seconds: 3),);

      var save = find.byValueKey('save');
      await driver.tap(save);
      await Future.delayed(const Duration(seconds: 5),);


    });


    test('adding promo code', () async {
      //
      // await Future.delayed(const Duration(seconds: 5),);
      //
      // var select = find.text("Cairo, Madinet Nasr ,Hadayq el-Qoubaa Street Flat Number: 6, Floor Number: 6 Building: 6 Additional directions: Next kher-zaman market");
      // await driver.tap(select);
      // await Future.delayed(const Duration(seconds: 3),);

      await driver.scroll(find.byValueKey('checkout'), 0 , -400.0, Duration(seconds: 2));

      var note = find.byValueKey('note');
      await driver.tap(note);
      await driver.enterText('thank you');
      await Future.delayed(const Duration(seconds: 3),);
      
      var promo_code = find.text('Enter voucher code');
      await driver.tap(promo_code);
      await Future.delayed(const Duration(seconds: 3),);

      var code = find.byValueKey('code');
      await driver.tap(code);
      await driver.enterText('5050');
      await Future.delayed(const Duration(seconds: 3),);

      var send = find.text('Send');
      await driver.tap(send);
      await Future.delayed(const Duration(seconds: 3),);

      var confirm = find.text('Confirm');
      await driver.tap(confirm);
      await Future.delayed(const Duration(seconds: 10),);


    });

  });
}





