class RestaurantFeaturesModel {
  bool canDineIn;
  bool canDeliver;
  bool canUseMenu;
  bool canBook;
  bool canUseChatBot;
  bool canPickUp;

  RestaurantFeaturesModel({
    this.canDineIn = false,
    this.canDeliver = false,
    this.canUseMenu = false});

  static RestaurantFeaturesModel fromJson(List<dynamic> activeModules) {
    RestaurantFeaturesModel restaurantModulesModel = RestaurantFeaturesModel();
    if (activeModules != null) {
      for (int i = 0; i < activeModules.length; i++) {
        switch (activeModules[i]
            [RestaurantModulesModelJsonKeys.RESTAURANT_MODULE_IDENTIFIER]) {
          case RestaurantModulesModelJsonKeys.RESTAURANT_MODULE_DINE_IN:
            restaurantModulesModel.canDineIn = true;
            continue;
          case RestaurantModulesModelJsonKeys.RESTAURANT_MODULE_DELIVERY:
            restaurantModulesModel.canDeliver = true;
            continue;
          case RestaurantModulesModelJsonKeys.RESTAURANT_MODULE_DIGITAL_MENU:
            restaurantModulesModel.canUseMenu = true;
            continue;
          case RestaurantModulesModelJsonKeys.RESTAURANT_MODULE_BOOKING:
            restaurantModulesModel.canBook = true;
            continue;
          case RestaurantModulesModelJsonKeys.RESTAURANT_MODULE_CHAT_BOT:
            restaurantModulesModel.canUseChatBot = true;
            continue;
          case RestaurantModulesModelJsonKeys.RESTAURANT_MODULE_PICK_UP:
            restaurantModulesModel.canPickUp = true;
            continue;
          default:
            continue;
        }
      }
    }
    return restaurantModulesModel;
  }
}

class RestaurantModulesModelJsonKeys {
  static const RESTAURANT_MODULE_IDENTIFIER = 'slug';
  static const RESTAURANT_MODULE_DELIVERY = 'canDeliver';
  static const RESTAURANT_MODULE_DINE_IN = 'canDineIn';
  static const RESTAURANT_MODULE_DIGITAL_MENU = 'canUseMenu';
  static const RESTAURANT_MODULE_BOOKING = 'canBook';
  static const RESTAURANT_MODULE_CHAT_BOT = 'canUseChatbot';
  static const RESTAURANT_MODULE_PICK_UP = 'canPickup';
}
