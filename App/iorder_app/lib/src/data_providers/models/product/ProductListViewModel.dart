import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:flutter/cupertino.dart';
import 'package:ande_app/src/utilities/ApiParseKeys.dart';
import 'ProductViewModel.dart';

class ProductListViewModel {
  var itemName, itemDescription;
  var itemId, itemCategoryId, itemImagePath;
  var itemBasePrice, itemRating;
  var isAvailable, isSpicy;

  ProductListViewModel({
    this.itemId,
    this.isSpicy,
    this.isAvailable,
    this.itemImagePath,
    this.itemName,
    this.itemDescription,
    this.itemBasePrice,
    this.itemRating,
    this.itemCategoryId,
  });

  @override
  int get hashCode => int.parse(itemId);

  @override
  bool operator ==(other) {
    return this.itemId == other.itemId;
  }

  ProductListViewModel deepCopy() {
    return ProductListViewModel(
      isAvailable: this.isAvailable,
      itemBasePrice: this.itemBasePrice,
      itemCategoryId: this.itemCategoryId,
      itemId: this.itemId,
      isSpicy: this.isSpicy,
      itemName: this.itemName,
      itemImagePath: this.itemImagePath,
      itemRating: this.itemRating,
    );
  }

  static ProductListViewModel fromJson(v) {
    try {

      return ProductListViewModel(
        itemBasePrice: ParseHelper.parseNumber(v[ApiParseKeys.MENU_ITEM_PRICE].toString()  , toDouble: true),
        itemDescription: v[ApiParseKeys.MENU_ITEM_DESCRIPTION] ?? '',
        itemName: v[ApiParseKeys.MENU_ITEM_NAME] ?? '',
        isSpicy: v[ApiParseKeys.MENU_ITEM_IS_SPICY] == 1 ?? false,
        itemImagePath: v[ApiParseKeys.MENU_ITEM_DEFAULT_IMAGE] ?? '',
        itemId: v[ApiParseKeys.MENU_ITEM_ID] ?? '1',
      );
    } catch (ex) {
      return null;
    }
  }

  static Iterable<ProductListViewModel> fromListJson(List<dynamic> menuItemsList) {
    List<ProductListViewModel> menuItems = List<ProductListViewModel>();
    if(menuItemsList != null && menuItemsList is List){
      for(int i = 0 ; i < menuItemsList.length ; i++){
        menuItems.add(fromJson(menuItemsList[i]));
      }
    }
    return menuItems;
  }
}
