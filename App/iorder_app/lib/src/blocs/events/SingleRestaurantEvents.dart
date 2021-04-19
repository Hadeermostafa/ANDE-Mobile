import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';

abstract class SingleRestaurantEvents {}

class LoadRestaurantDetails extends SingleRestaurantEvents {
  final String restaurantId;
  final RestaurantLoadingType as;
  LoadRestaurantDetails({this.restaurantId, this.as});
}


class LoadRestaurantMenu extends SingleRestaurantEvents {
  final String restaurantId;
  final RestaurantLoadingType as;
  final String languageCode ;
  LoadRestaurantMenu(this.languageCode,  {this.restaurantId, this.as });
}
