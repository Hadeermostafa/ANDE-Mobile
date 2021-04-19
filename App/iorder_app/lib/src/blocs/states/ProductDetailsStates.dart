import 'package:ande_app/src/blocs/events/ProductDetailsEvents.dart';
import 'package:ande_app/src/data_providers/models/ErrorViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductViewModel.dart';

abstract class ProductDetailsStates {}

class ProductInformationLoadingState extends ProductDetailsStates {}

class ProductInformationFailedState extends ProductDetailsStates {
  final ErrorViewModel error;
  final ProductDetailsEvents failedEvent;
  ProductInformationFailedState({this.failedEvent , this.error});
}

class ProductInformationLoaded extends ProductDetailsStates {
  ProductViewModel mealModel;
  ProductInformationLoaded({this.mealModel});
}

class WaiterCallLoading extends ProductDetailsStates {}

class WaiterCallSuccess extends ProductDetailsStates {}

class WaiterCallFailed extends ProductDetailsStates {}
