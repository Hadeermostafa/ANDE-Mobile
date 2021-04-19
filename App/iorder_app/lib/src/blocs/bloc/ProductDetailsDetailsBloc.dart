import 'package:ande_app/src/blocs/events/ProductDetailsEvents.dart';
import 'package:ande_app/src/blocs/states/ProductDetailsStates.dart';
import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/data_providers/models/ResponseModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/Repository.dart';
import 'package:ande_app/src/utilities/NetworkUtilities.dart';
import 'package:bloc/bloc.dart';



class ProductDetailsBloc
    extends Bloc<ProductDetailsEvents, ProductDetailsStates> {
  @override
  ProductDetailsStates get initialState => ProductInformationLoadingState();
  List<OrderItemViewModel> userItems = [];
  ProductViewModel fetchedMeal;

  void addNewItem() {
    if (userItems.length >= 1) {
      OrderItemViewModel clone = userItems[0].deepCopy();
      clone.userNote = '';
      userItems.add(clone);
    } else {
      userItems.add(
        OrderItemViewModel(
          userNote: '',
          itemViewModel: fetchedMeal,
          itemStatues: ItemStatues.ITEM_STATUES_SENT,
          // mealExtrasMap: _initializeMandatoryExtras(fetchedMeal),
          mealSize: fetchedMeal.sizes != null &&
                  fetchedMeal.sizes.length > 0
              ? fetchedMeal.sizes[0].deepCopy()
              : null,
          orderItemId: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  void removeItem() {
    userItems.removeLast();
  }

  void updateSize(ProductAddOn newSize, int index) {
    userItems[index].mealSize = newSize;
  }

  void updateExtras(
      List<ProductAddOn> newExtras, int index) {
    // userItems[index].mealExtrasMap.clear();
    // userItems[index].mealExtrasMap.addAll(newExtras);
    // userItems[index].mealExtrasMap.keys.toList().forEach((k) {});
    userItems[index].userSelectedExtras = newExtras;

  }

  void updateItemNote(String userNote, index) {
    userItems[index].userNote = userNote;
  }

  void deleteItemAt(int index) {
    if (index > -1 && index < userItems.length) userItems.removeAt(index);
  }

  @override
  Stream<ProductDetailsStates> mapEventToState(
      ProductDetailsEvents event) async* {
    bool isConnected = await NetworkUtilities.isConnected();
    if (isConnected == false) {
      yield ProductInformationFailedState(failedEvent: event , error: Constants.connectionTimeoutException);
      return;
    }
    if (event is LoadProductInformation) {
      yield* _handleProductInformationLoadingEvent(event);
      return ;
    }
    if (event is CallWaiterForError) {
      yield* _handleCallWaiterEvent(event);
    }
  }

  void updateQuantity(int index) {
    if (index > -1 && index < userItems.length) userItems[index].quantity++;
  }

  void duplicateItemAtIndex(int itemIndex) {
    userItems[itemIndex].quantity++;
  }

  int getTotalItemsCount() {
    int itemsCount = 0;
    for (int i = 0; i < userItems.length; i++) {
      itemsCount += userItems[i].quantity;
    }
    return itemsCount;
  }

  int getDrawingItemsCount() {
    return userItems.length;
  }

  Stream<ProductDetailsStates> _handleProductInformationLoadingEvent(LoadProductInformation event) async*{
    ResponseViewModel serverResponse = await Repository.getItemInformation(event.restaurantId, event.productId, event.language);
    if (serverResponse.isSuccess) {
      fetchedMeal = serverResponse.responseData;
      userItems = List();
      addNewItem();
      yield ProductInformationLoaded(mealModel: serverResponse.responseData);
      return;
    } else {
      yield ProductInformationFailedState(failedEvent: event , error: serverResponse.serverError);
    }
  }

  Stream<ProductDetailsStates> _handleCallWaiterEvent(CallWaiterForError event) async* {
    yield WaiterCallLoading();
    ResponseViewModel response = await Repository.callWaiter(tableId: event.tableId);
    if (response.isSuccess) {
      yield WaiterCallSuccess();
      return;
    }  else {
      yield WaiterCallFailed();
      return;
    }
  }
}
