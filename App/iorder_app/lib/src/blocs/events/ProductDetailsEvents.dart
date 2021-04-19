abstract class ProductDetailsEvents {}

class LoadProductInformation extends ProductDetailsEvents {
  final String productId;
  final String restaurantId;
  final String language;
  LoadProductInformation({this.productId, this.restaurantId, this.language});
}

class CallWaiterForError extends ProductDetailsEvents {
  final String tableId;
  CallWaiterForError({this.tableId});
}
