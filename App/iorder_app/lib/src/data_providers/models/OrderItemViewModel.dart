import 'package:ande_app/src/data_providers/models/product/ProductViewModel.dart';
import 'package:flutter/material.dart';

class OrderItemViewModel implements Comparable {
  List<ProductAddOn> userSelectedExtras = List<ProductAddOn>();
  ProductAddOn mealSize;
  ProductViewModel itemViewModel;
  var orderItemId, quantity = 1;
  String userNote = "";
  ItemStatus itemStatues;
  bool isPlaced = false;


  @override
  String toString() {
    return 'OrderItemViewModel{userSelectedExtras: ${userSelectedExtras != null ? userSelectedExtras.length : 0}, mealSize: ${mealSize.toString()}';
  }

  deepCopy() {
   List<ProductAddOn> selectedExtras = List();

   try{
     for(int i = 0 ; i < userSelectedExtras.length ; i++)
       selectedExtras.add(userSelectedExtras[i].deepCopy());
   } catch(exceptionWhileCopyingItems){
     debugPrint("Exception copy item extras => $exceptionWhileCopyingItems");
   }


    return OrderItemViewModel(
      userNote: this.userNote,
      itemStatues: this.itemStatues,
      userSelectedExtras : selectedExtras,
      mealSize: this.mealSize.deepCopy(),
      itemViewModel: this.itemViewModel,
      orderItemId: DateTime.now().millisecondsSinceEpoch,
    );
  }

  bool validateItem() {
    return mealSize != null;
  }

  OrderItemViewModel(
      {this.orderItemId,
        this.userSelectedExtras,
        this.mealSize,
        this.userNote,
        this.itemStatues,
        this.itemViewModel,
        this.isPlaced = false});

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(other) {
    return orderItemId == other.orderItemId;
  }

  @override
  int compareTo(other) {
    if (orderItemId == other.orderItemId)
      return 0;
    else if (orderItemId > other.orderItemId)
      return 1;
    else
      return -1;
  }

  double calculateItemPrice() {
    double extraPrice = 0.0, itemBasePrice = 0;
    if (mealSize != null) {
      itemBasePrice = mealSize.price;
    }
    if(userSelectedExtras != null) {
      for (int i = 0; i < userSelectedExtras.length; i++)
        extraPrice += userSelectedExtras[i].price;
    }
    return extraPrice + itemBasePrice;
  }

  static fromJson(itemJson) {
    return OrderItemViewModel(
    );
  }
  static ItemStatus getItemStatues(itemJson) {
    switch (itemJson) {
      case OrderItemJsonKeys.ITEM_STATUES_SENT:
        return ItemStatues.ITEM_STATUES_SENT;
      case OrderItemJsonKeys.ITEM_STATUES_PREPARING:
        return ItemStatues.ITEM_STATUES_PREPARING;
      case OrderItemJsonKeys.ITEM_STATUES_PREPARED:
        return ItemStatues.ITEM_STATUES_PREPARING;
      case OrderItemJsonKeys.ITEM_STATUES_SERVED:
        return ItemStatues.ITEM_STATUES_SERVED;
      case OrderItemJsonKeys.ITEM_STATUES_NEW:
        return ItemStatues.ITEM_STATUES_SENT;
      case OrderItemJsonKeys.ITEM_STATUES_PAID:
        return ItemStatues.ITEM_STATUES_PAID;
      default:
        return ItemStatues.ITEM_STATUES_SENT;
    }
  }

}

//enum ITEM_STATUES { SENT, PREPARING, SERVED }

class OrderItemJsonKeys {
  static const ITEM_ID = "id";
  static const ITEM_NAME = "name";
  static const ITEM_NOTE = "note";
  static const ITEM_INGREDIENTS = "ingredient";
  static const ITEM_PHOTO = "mainPhoto";
  static const ITEM_STATUES = "status";
  static const ITEM_SIZE = "size";
  static const ITEM_EXTRAS = "extras";
  static const ITEM_OPTIONS = "options";

  static const ITEM_STATUES_SENT = "Sent";
  static const ITEM_STATUES_PREPARING = "Preparing";
  static const ITEM_STATUES_PREPARED = "Prepared";

  static const ITEM_STATUES_SERVED = "Served";
  static const ITEM_STATUES_NEW = "New";
  static const ITEM_STATUES_PAID = "Paid";
}

class ItemStatues {
  static const ItemStatus ITEM_STATUES_SENT = const ItemStatus(
      stateNameEn: "Sent",
      stateNameAr: "وصل",
      stateColor: Colors.red,
      statuesRank: 1);
  static const ItemStatus ITEM_STATUES_PREPARING = const ItemStatus(
      stateNameEn: "Preparing",
      stateNameAr: "جاري تحضيره",
      stateColor: Colors.orange,
      statuesRank: 2);
  static const ItemStatus ITEM_STATUES_SERVED = const ItemStatus(
      stateNameEn: "Served",
      stateNameAr: "تم تقديمه",
      stateColor: Colors.green,
      statuesRank: 3);
  static const ItemStatus ITEM_STATUES_PAID = const ItemStatus(
      stateNameEn: "Paid",
      stateNameAr: "تم الدفع",
      stateColor: Colors.black,
      statuesRank: 4);
}

class ItemStatus {
  final int statuesRank;
  final String stateNameEn, stateNameAr;
  final Color stateColor;
  const ItemStatus(
      {this.stateColor, this.stateNameEn, this.stateNameAr, this.statuesRank});

  @override
  bool operator ==(Object other) {
    if (other is ItemStatus) {
      return (this.statuesRank == other.statuesRank) &&
          (this.stateNameEn == other.stateNameEn) &&
          (this.stateNameAr == other.stateNameAr) &&
          (this.stateColor == other.stateColor);
    }
  }

  @override
  int get hashCode {

  }
}
