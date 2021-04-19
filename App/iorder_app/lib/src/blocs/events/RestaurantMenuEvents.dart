abstract class RestaurantMenuEvents {}
class LoadRestaurantMenu extends RestaurantMenuEvents{
  final String language ;
  final String restaurantId ;
  LoadRestaurantMenu({this.language , this.restaurantId});
}
