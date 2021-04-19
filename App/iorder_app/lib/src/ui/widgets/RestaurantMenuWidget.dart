import 'dart:io';

import 'package:ande_app/main.dart';
import 'package:ande_app/src/blocs/bloc/RestaurantMenuBloc.dart';
import 'package:ande_app/src/blocs/events/RestaurantMenuEvents.dart';
import 'package:ande_app/src/blocs/states/RestaurantMenuStates.dart';
import 'package:ande_app/src/data_providers/models/LanguageModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantListViewModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantMenuModel.dart';
import 'package:ande_app/src/data_providers/models/RestaurantViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductCategoryViewModel.dart';
import 'package:ande_app/src/data_providers/models/product/ProductListViewModel.dart';
import 'package:ande_app/src/resources/Constants.dart';
import 'package:ande_app/src/resources/external_resource/AndeImageNetwork.dart';
import 'package:ande_app/src/ui/dialogs/MenuLanguageDialog.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/HelperFunctions.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../list_tiles/ProductTile.dart';
import 'ListViewAnimatorWidget.dart';
class RestaurantMenuWidget extends StatefulWidget {
  final RestaurantViewModel restaurantModel;
  final Function onMenuItemClicked , onMenuLanguageChange;
  final LanguageModel languageModel;
  RestaurantMenuWidget({this.restaurantModel , this.languageModel , this.onMenuLanguageChange ,this.onMenuItemClicked});

  @override
  _RestaurantMenuWidgetState createState() => _RestaurantMenuWidgetState();
}

class _RestaurantMenuWidgetState extends State<RestaurantMenuWidget> with TickerProviderStateMixin {


  BehaviorSubject<bool> behaviour =  BehaviorSubject<bool>();
  TabController  tabController ;
  int tabBarIndex = 0 ;
  LanguageModel menuLanguage;
  RestaurantMenuBloc restaurantMenuBloc ;

  @override
  void initState() {
    super.initState();
    menuLanguage = widget.languageModel;
    restaurantMenuBloc = RestaurantMenuBloc();
    restaurantMenuBloc.add(LoadRestaurantMenu(restaurantId: widget.restaurantModel.restaurantListViewModel.restaurantId.toString(), language: menuLanguage.localeCode));
    tabController = TabController(length: 0, vsync: this , initialIndex: 0);
  }


  List<Widget> getVisibleTabs(RestaurantMenuModel dataModel) {
    List<Widget> tabsList = [];
    try{
      dataModel.restaurantSupportedCategories.forEach((ProductCategoryViewModel category) {
        if(category.categoryProducts.isNotEmpty){
          tabsList.add(Container(child: FittedBox(
            child: Text(
              category.categoryName,
              textScaleFactor: 1,
              style: TextStyle(
                  fontSize: 14, fontFamily: Constants.FONT_MONTSERRAT),
            ),
          ),),);
        } else {
          //dataModel.restaurantSupportedCategories.remove(category);
        }
      });
    } catch(exception){}
    return tabsList;
  }
  List<ProductCategoryViewModel> getVisibleCategories(RestaurantMenuModel dataModel) {
    List<ProductCategoryViewModel> categoriesList = [];
    try{
      dataModel.restaurantSupportedCategories.forEach((ProductCategoryViewModel category) {
        if(category.categoryProducts.isNotEmpty){
          categoriesList.add(category);
        } else {
          //dataModel.restaurantSupportedCategories.remove(category);
        }
      });
    } catch(exception){}
    return categoriesList;
  }

  Future<void> showLocalePickerDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: MenuAvailableLanguageDialog(
              title: (LocalKeys.AVAILABLE_LANGUAGE).tr(),
              onLanguageSelected: (LanguageModel selectedModel) {
                Constants.currentRestaurantLocale = selectedModel.localeCode;
                menuLanguage = selectedModel;
                restaurantMenuBloc.add(LoadRestaurantMenu(language: menuLanguage.localeCode , restaurantId: widget.restaurantModel.restaurantListViewModel.restaurantId.toString()));
                Navigator.of(context).pop();
                return;
              },
              preSelectedLang: menuLanguage,
              restaurantLanguages: widget.restaurantModel.languagesList,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return HelperWidget.resolveDirectionality(
        child: Expanded(
          child: ListView(
            children: <Widget>[
              SizedBox(
                child: StreamBuilder<bool>(
                  stream: behaviour.stream,
                  initialData: true,
                  builder: (context, snapshot) {
                    return screenHeader(widget.restaurantModel.restaurantListViewModel);
                  }
                ),
                height: 155,
              ),
              SizedBox(
                height: 7,
              ),
              BlocConsumer(
                listener: (context, state) async{
                  if(state is RestaurantMenuLoaded){
                    widget.onMenuLanguageChange(state.menu);
                    return;
                  }
                  else if (state is RestaurantMenuLoadingFailedState){
                    if (state.error.errorCode == HttpStatus.requestTimeout) {
                      HelperWidget.showNetworkErrorDialog(context);
                      await Future.delayed(Duration(seconds: 2), () {});
                      HelperWidget.removeNetworkErrorDialog(context);
                      await Future.delayed(Duration(seconds: 5), () {
                        restaurantMenuBloc.add(state.failedEvent);
                      });
                    }
                    else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
                      HelperWidget.showToast(message: (LocalKeys.SERVER_UNREACHABLE).tr() , isError: true);
                    } else if (state.error.errorCode != 401) {
                      HelperWidget.showToast(message: state.error.errorMessage , isError: true);
                    }
                  }
                },
                bloc: restaurantMenuBloc,
                builder: (context, state){
                  if(state is RestaurantMenuLoaded){
                    widget.restaurantModel.restaurantMenuModel = state.menu;
                    widget.restaurantModel.restaurantListViewModel.restaurantName = state.menu.restaurantName;
                    widget.restaurantModel.restaurantDescription = state.menu.restaurantDescription;
                    tabController = TabController(length: getVisibleTabs(widget.restaurantModel.restaurantMenuModel,).length, vsync: this , initialIndex: tabBarIndex);
                    behaviour.sink.add(true);
                  }
                  return  state is RestaurantMenuLoaded ?
                  SingleChildScrollView(child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            height: 35,
                            child: TabBar(
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey[900],
                              ),
                              isScrollable: true,
                              labelColor: Colors.white,
                              unselectedLabelColor: Constants.kTextColor,
                              tabs: getVisibleTabs(widget.restaurantModel.restaurantMenuModel,),
                              controller: tabController,
                              onTap: (selectedIndex) {
                                tabBarIndex = selectedIndex;
                                setState(() {});
                              },
                              indicatorWeight: 2,
                              indicatorSize: TabBarIndicatorSize.tab,
                            ),
                          ),
                        ),
                        getItemsList(),
                      ],
                    ),) : Container(
                    child: Center(child: loadingFlare,),
                  );
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).orientation ==
                    Orientation.portrait
                    ? 50
                    : 70,
              ),
            ],
          ),
        ),
        targetWidgetName:
        'SingleRestaurantMenuScreen => Menu Body',
        context: context,
        locale: Constants.currentRestaurantLocale,
      );
  }
  Widget screenHeader(RestaurantListViewModel dataModel) {
    return Container(
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          AndeImageNetwork(
            widget.restaurantModel.restaurantCover,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width,
            height: 155,
            constrained: true,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              backgroundBlendMode: BlendMode.darken,
            ),
            width: MediaQuery.of(context).size.width,
            height: 155,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  child: AndeImageNetwork(
                    dataModel.restaurantImagePath,
                    width: 60,
                    height: 60,
                    constrained: true,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        '${widget.restaurantModel.restaurantListViewModel.restaurantName}',
                        textAlign: TextAlign.start,
                        textScaleFactor: 1,
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: Constants.FONT_MONTSERRAT,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        UIHelper.getCategoriesAsList(dataModel.restaurantCuisines),
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: Constants.FONT_MONTSERRAT,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(.8),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${widget.restaurantModel.restaurantDescription}',
                        textAlign: TextAlign.start,
                        textScaleFactor: 1,
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: Constants.FONT_MONTSERRAT,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: widget.languageModel != null,
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: SizedBox(
                width: 100,
                child: FittedBox(
                  child: FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () async {
                        await showLocalePickerDialog();
                      },
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            menuLanguage.localeName,
                            textScaleFactor: 1,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
                      )),
                ),
              ),
            ),
            replacement: Container(width: 5, height: 10,),
          ),
        ],
      ),
    );
  }


  //------------------------------------ FILTER LOGIC----------------------------------------



  @override
  void dispose() {
    behaviour.close();
    super.dispose();
  }

  Widget getItemsList() {

    bool restaurantLoaded = widget.restaurantModel.restaurantMenuModel != null;
    bool restaurantItemsLoaded = widget.restaurantModel.restaurantMenuModel.restaurantSupportedCategories != null;

    if(restaurantLoaded && restaurantItemsLoaded)
      return ListViewAnimatorWidget(
      isScrollEnabled: false,
      listChildrenWidgets: getVisibleCategories(widget.restaurantModel.restaurantMenuModel)
      [tabBarIndex].categoryProducts.map((ProductListViewModel product) => ProductTile(
          widget.restaurantModel.restaurantCurrency.currencyName,
        onItemClicked: () {
          widget.onMenuItemClicked(product);
          return;
        },
        dataModel: product,
      )).toList(),
    );
    else
      return Container();
  }



}
