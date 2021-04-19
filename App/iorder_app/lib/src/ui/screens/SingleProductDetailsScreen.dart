import 'dart:io';

import 'package:ande_app/main.dart';
import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductViewModel.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:ande_app/src/ui/dialogs/AndeOnTheWayDialog.dart';
import 'package:ande_app/src/ui/dialogs/DeleteItemsPopup.dart';
import 'package:ande_app/src/ui/list_tiles/ProductCustomizationClosedStateTile.dart';
import 'package:ande_app/src/ui/screens/LandingScreen.dart';
import 'package:ande_app/src/ui/screens/RestaurantSplashScreen.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/VideoPlayerWidget.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rxdart/rxdart.dart';

import '../../blocs/bloc/ProductDetailsDetailsBloc.dart';
import '../../blocs/events/ProductDetailsEvents.dart';
import '../../blocs/states/ProductDetailsStates.dart';
import '../../resources/Constants.dart';
import '../../resources/UserCart.dart';
import '../list_tiles/ProductItemCustomizationTile.dart';
import '../widgets/counter_widget.dart';

class SingleProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String language;
  final RestaurantViewModel restaurantInfo ;
  final RestaurantLoadingType restaurantType;

  SingleProductDetailsScreen(
      {this.productId, this.productName, this.restaurantInfo ,this.language, this.restaurantType});

  @override
  _SingleProductDetailsScreenState createState() =>
      _SingleProductDetailsScreenState();
}

class _SingleProductDetailsScreenState extends State<SingleProductDetailsScreen>
    with TickerProviderStateMixin {
  double totalItemPrice = 0;
  ProductDetailsBloc productDetailsBloc;
  int activeTileIndex = 0;
  GlobalKey<AnimatedListState> animatedListController =
      GlobalKey<AnimatedListState>();

  BehaviorSubject<void> reloadPrice = BehaviorSubject<void>();

  AnimationController animController;
  Animation animation;

  onTileClicked(int index) {
    activeTileIndex = index;
    setState(() {});
  }

  onSizePicked(ProductAddOn sizeViewModel, int index) {
    productDetailsBloc.updateSize(sizeViewModel, index);
    reloadPrice.sink.add(null);
  }

  onUpdateUserNotes(String userNote, int index) {
    productDetailsBloc.updateItemNote(userNote, index);
  }

  onDuplicate(int itemIndex) {
    productDetailsBloc.duplicateItemAtIndex(itemIndex);
    reloadPrice.sink.add(null);
    setState(() {});
  }

  onDeleteItemClicked(int index) {
    productDetailsBloc.deleteItemAt(index);
    animatedListController.currentState.removeItem(index, (context, index) {
      return Container();
    });

    if (productDetailsBloc.userItems.length == 0) Navigator.pop(context);

    if (productDetailsBloc.userItems.length > 0) {
      reloadPrice.sink.add(null);
      setState(() {});
    }
  }

  onExtraUpdate(List<ProductAddOn> productExtras, int index) {
    productDetailsBloc.updateExtras(productExtras, index);
    reloadPrice.sink.add(null);
  }

  onSilentExtraUpdate(List<ProductAddOn> productExtras, int index) {
    productDetailsBloc.updateExtras(productExtras, index);
    reloadPrice.sink.add(null);
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  ProductViewModel dataItem;

  @override
  void initState() {
    super.initState();
    productDetailsBloc = ProductDetailsBloc();
    productDetailsBloc.add(LoadProductInformation(
        productId: widget.productId,
        restaurantId: widget.restaurantInfo.restaurantListViewModel.restaurantId.toString(),
        language: widget.language));
    animController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: true,
        appBar: AndeAppbar(
          hasBackButton: true,
          screenTitle:
              widget.productName ?? (LocalKeys.ORDER_SCREEN_TITLE).tr(),
        ),
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: BlocConsumer(
              bloc: productDetailsBloc,
              buildWhen: (previous, current) => previous != current,
              listener: (context, state) async{
                if (state is ProductInformationFailedState) {
                  if (state.error.errorCode == HttpStatus.requestTimeout) {
                    HelperWidget.showNetworkErrorDialog(context);
                    await Future.delayed(Duration(seconds: 2), () {});
                    HelperWidget.removeNetworkErrorDialog(context);

                    Future.delayed(
                      Duration(seconds: 5),
                      () {
                        productDetailsBloc.add(state.failedEvent);
                      },
                    );
                  }
                }
                if (state is WaiterCallSuccess) {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => AndeOnTheWayDialog());
                }
              },
              builder: (context, state) {
                return ModalProgressHUD(
                  child: resolveChild(state),
                  inAsyncCall: state is ProductInformationLoadingState ||
                      state is WaiterCallLoading,
                  progressIndicator: loadingFlare,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  screenHeader() {
    return Material(
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                spreadRadius: .5,
                blurRadius: 10,
                color: Colors.black45.withOpacity(.1),
              ),
            ],
            color: Colors.white,
            border: Border(
                top: BorderSide(
              color: Colors.black12,
              width: .3,
            ))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * .2,
                width: MediaQuery.of(context).size.width,
                child: dataItem.media.length > 0 ?
                Swiper(
                  pagination: new SwiperPagination(),
                  itemCount: dataItem.media.length,
                  onTap: (index) {},
                  scrollDirection: Axis.horizontal,
                  layout: SwiperLayout.DEFAULT,
                  itemBuilder: (context, index) {
                    if (dataItem.media[index].source == MEDIA_SOURCE.IMAGE) {
                      return AndeImageNetwork(
                        dataItem.media[index].url,
                        constrained: false,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return MediaPlayerWidget(
                        videoURL: dataItem.media[index].url,
                      );
                    }
                  },
                ) :
                Container(
                  color: Constants.AndeLogoColor,
                  child: AndeImageNetwork(
                      '',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 8.0),
              child: Text(
                dataItem.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(dataItem.description ?? ''),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void updatePrice() {
    totalItemPrice = 0.0;

    productDetailsBloc.userItems.forEach((orderSingleItem) {
      double cardPrice = 0.0;
      if (orderSingleItem.mealSize != null) {
        cardPrice = orderSingleItem.mealSize.price;
      }
      if (orderSingleItem.userSelectedExtras != null) {
        orderSingleItem.userSelectedExtras.forEach((value) {
          cardPrice += value.price;
        });
      }
      cardPrice *= orderSingleItem.quantity;
      totalItemPrice += cardPrice;
    });
  }

  Widget getErrorView(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.warning,
              size: 50,
              color: Colors.red[800],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                (LocalKeys.ITEM_NOT_EXIST).tr(),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 150,
              child: ButtonTheme(
                highlightColor: Colors.transparent,
                height: 100,
                child: FlatButton(
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey,
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          (LocalKeys.RETRY).tr(),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ).tr(),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.refresh,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ButtonTheme(
              height: 60,
              child: RaisedButton(
                key: GlobalKey(),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 0.5,
                    color: Colors.black.withOpacity(.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                color: Colors.white,
                onPressed: () {
                  productDetailsBloc.add(
                      CallWaiterForError(tableId: UserCart().orderTableNumber));
                },
                child: Text(
                  (LocalKeys.CALL_WAITER).tr(),
                  key: GlobalKey(),
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: Colors.black.withOpacity(.8),
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    reloadPrice.close();
    super.dispose();
  }

  resolveChild(ProductDetailsStates state) {
    if (state is ProductInformationLoaded) {
      dataItem = state.mealModel;
      return Stack(
        children: <Widget>[
          SingleChildScrollView( key: Key('item wedgit'),
            child: Column(
              children: <Widget>[
                screenHeader(),
                SizedBox(
                  height: 25,
                ),
                CounterWidget(
                  counter: productDetailsBloc.getTotalItemsCount(),
                  height: 40,
                  width: MediaQuery.of(context).size.width * .4,
                  onPlusPressed: () {
                    bool isValid = productDetailsBloc
                        .userItems[productDetailsBloc.userItems.length - 1]
                        .validateItem();
                    if (isValid == false) {
                      HelperWidget.showToast(
                          message: (LocalKeys.EMPTY_FIELD_REQUIRED).tr(),
                          isError: true);
                      return;
                    }

                    animatedListController.currentState.insertItem(
                        productDetailsBloc.userItems.length - 1,
                        duration: Duration(seconds: 5));
                    productDetailsBloc.addNewItem();
                    activeTileIndex = productDetailsBloc.userItems.length - 1;
                    updatePrice();
                    setState(() {});
                  },
                  onMinusPressed: () async {
                    List<OrderItemViewModel> items = await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => DeleteItemsPopup(
                        widget.restaurantInfo.restaurantCurrency.currencyName,
                        itemsList: productDetailsBloc.userItems,
                      ),
                    );
                    if (items != null && items.length > 0) {
                      productDetailsBloc.userItems = items;
                    }
                    if (productDetailsBloc.userItems.length == 0)
                      Navigator.pop(context);
                    if (productDetailsBloc.userItems.length > 0) {
                      reloadPrice.sink.add(null);
                      setState(() {});
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                AnimatedList(
                    primary: true,
                    scrollDirection: Axis.vertical,
                    key: animatedListController,
                    reverse: true,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    initialItemCount: productDetailsBloc.userItems.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= productDetailsBloc.userItems.length) {
                        return Container(
                          width: 0,
                          height: 0,
                        );
                      }

                      if (index == activeTileIndex) {
                        return AnimationConfiguration.staggeredList(
                          delay: Duration(milliseconds: 50),
                          position: index,
                          duration: const Duration(milliseconds: 200),
                          child: SlideAnimation(
                            horizontalOffset: 300.0,
                            child: FadeInAnimation(
                              child: ProductItemCustomizationTile(
                                widget.restaurantInfo.restaurantCurrency.currencyName,
                                shouldAnimate: true,
                                orderItemViewModel: productDetailsBloc.userItems[index],
                                itemIndex: index,
                                onItemClicked: onTileClicked,
                                onDuplicateItem: onDuplicate,
                                onEditingComplete: onUpdateUserNotes,
                                onExtraUpdate: onExtraUpdate,
                                onSilentUpdate: onSilentExtraUpdate,
                                onSizeSelected: onSizePicked,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return ProductCustomizationClosedStateTile(
                          shouldAnimate: true,
                          orderItemViewModel:
                              productDetailsBloc.userItems[index],
                          itemIndex: index,
                          onItemClicked: onTileClicked,
                        );
                      }
                    }),
                Container(
                  height: 70,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            height: 70,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.bottomCenter,
                child: ButtonTheme(
                    padding: EdgeInsets.all(0),
                    height: 60,
                    minWidth: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlatButton(key: Key('confirm'),
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          if (widget.restaurantType == RestaurantLoadingType.DINING) {
                            if (widget.restaurantInfo.restaurantModulesModel.canDineIn == false) {
                              if (widget.restaurantInfo.restaurantModulesModel.canUseMenu == true) {
                                HelperWidget.showToast(
                                    message: tr(LocalKeys.RESTAURANT_NO_DINE_IN),
                                    isError: true);
                                return;
                              }  else {
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                    builder: (context) => LandingScreen()) , (_)=> false);
                                return;
                              }
                            }
                          }
                          bool validScreen = true;
                          productDetailsBloc.userItems.forEach((orderItemVM) {
                            validScreen =
                                validScreen && orderItemVM.validateItem();
                          });

                        if (productDetailsBloc.userItems.length > 0 &&
                            validScreen) {
                          UserCart().addToCart(
                              itemsAsList: productDetailsBloc.userItems);
                          Navigator.pop(context);
                        } else {
                          HelperWidget.showToast(
                              message: (LocalKeys.EMPTY_FIELD_REQUIRED).tr(),
                              isError: true);
                          return;
                        }
                      },
                      child: StreamBuilder<void>(
                          stream: reloadPrice,
                          builder: (context, snapshot) {
                            updatePrice();
                            return Text(
                              '${(LocalKeys.CONFIRM_LABEL).tr()} (${totalItemPrice.truncateToDouble().toStringAsFixed(2)} ${ widget.restaurantInfo.restaurantCurrency.currencyName ??  (Constants.currentRestaurantCurrency)})',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            );
                          }),
                      color: (productDetailsBloc.userItems.length > 0)
                          ? Colors.grey[850]
                          : Colors.grey,
                    ),
                  )),
            ),
          ),
          )],
      );
    } else if (state is ProductInformationFailedState ||
        state is WaiterCallFailed ||
        state is WaiterCallSuccess) {
      return getErrorView(context);
    } else {
      return Container();
    }
  }
}
