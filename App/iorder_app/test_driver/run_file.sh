echo "login to the app"
flutter driver --target=test_driver/app.dart --driver=test_driver/base.dart
echo "create delivery order"
flutter driver --target=test_driver/app.dart --driver=test_driver/delivery.dart
echo "finish"
read ANDE