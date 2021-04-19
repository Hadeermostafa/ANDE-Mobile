import 'package:ande_app/src/data_providers/models/product/ProductViewModel.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/ui/widgets/lineContainer.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../data_providers/models/OrderItemViewModel.dart';
import '../../resources/Constants.dart';
import '../../resources/external_resource/CheckBoxListTile.dart';
import '../../resources/external_resource/RadioButtonListTile.dart';

class ProductItemCustomizationTile extends StatefulWidget {
  final int itemIndex;
  final String currencyName ;
  final bool shouldAnimate;
  final Function onSizeSelected,
      onExtraUpdate,
      onSilentUpdate,
      onRemoveClicked,
      onEditingComplete,
      onItemClicked,
      onDuplicateItem;

  final OrderItemViewModel orderItemViewModel;

  ProductItemCustomizationTile(
      this.currencyName,
      {this.itemIndex,
        this.shouldAnimate,
        this.onSilentUpdate,
        this.onExtraUpdate,
        this.onRemoveClicked,
        this.onSizeSelected,
        this.onItemClicked,
        this.onEditingComplete,
        this.orderItemViewModel,
        this.onDuplicateItem});

  @override
  _ProductItemCustomizationTileState createState() =>
      _ProductItemCustomizationTileState();
}

class _ProductItemCustomizationTileState extends State<ProductItemCustomizationTile> {
  List<ProductAddOn> itemExtras = List<ProductAddOn>();
  ProductAddOn selectedSize;
  TextEditingController customerHintController = TextEditingController();
  BehaviorSubject<void> _reloadStream = BehaviorSubject<void>();

  @override
  void initState() {
    super.initState();
    if (widget.orderItemViewModel.mealSize != null) selectedSize = widget.orderItemViewModel.mealSize;
    if (widget.orderItemViewModel.userNote != null && widget.orderItemViewModel.userNote.isNotEmpty) {
      customerHintController =
          TextEditingController(text: widget.orderItemViewModel.userNote);
    }
    if(widget.orderItemViewModel.userSelectedExtras != null){
      for(int i = 0 ; i < widget.orderItemViewModel.userSelectedExtras.length ; i++){
        itemExtras.add(widget.orderItemViewModel.userSelectedExtras[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String appLocale = Constants.currentAppLocale,
    menuLocal = Constants.currentRestaurantLocale;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        widget.onItemClicked(widget.itemIndex);
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[200],
                ),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFFCFCFC),
                        border:
                        Border(bottom: BorderSide(color: Colors.grey[200],), top: BorderSide(color: Colors.grey[200]))),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 8, top: 15, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.orderItemViewModel.itemViewModel.name,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey[400]),
                                color: Colors.white),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  (widget.itemIndex + 1).toString(),
                                  textScaleFactor: 0.8,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.onRemoveClicked != null,
                            replacement: Container(
                              width: 0,
                              height: 0,
                            ),
                            child: Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Constants.mainThemeColor,
                                    ),
                                    child: Center(
                                      child: IconButton(key: Key('delete'),
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                        icon: Icon(
                                          Icons.remove,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          widget.onRemoveClicked(widget.itemIndex);
                                          return;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    height: 1,
                    color: Colors.grey[200],
                    width: MediaQuery.of(context).size.width,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ConfigurableExpansionTile(
                    initiallyExpanded: true,
                    animatedWidgetFollowingHeader: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.5),
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 25,
                      ),
                    ),
                    headerExpanded: HelperWidget.resolveDirectionality(
                        child: Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                      child: Text(
                                        '${(LocalKeys.SIZES_LABEL).tr()} *',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ).tr()),
                                ],
                              ),
                            )),
                        locale: appLocale,
                        context: context),
                    header: HelperWidget.resolveDirectionality(
                        child: Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                      child: Text(
                                        (LocalKeys.SIZES_LABEL).tr(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )),
                                ],
                              ),
                            )),
                        locale: appLocale,
                        context: context),
                    children: [
                      HelperWidget.resolveDirectionality(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: getItemSizesAsWidgetList(),
                          ),
                          locale: menuLocal,
                          context: context),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  LineContainer(),
                  //------------------- Extras //----------------
                  getExtrasAsList(appLocale: appLocale , menuLocal: menuLocal),
                  Padding(
                    padding:
                    const EdgeInsets.only(right: 10, left: 10 , top: 10 , bottom: 20),
                    child: TextField(
                      key: Key('note'),
                      maxLines: 2,
                      cursorColor: Colors.grey[900],
                      controller: customerHintController,
                      onChanged: (text) {
                        widget.onEditingComplete(
                            customerHintController.text, widget.itemIndex);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                        hintText: (LocalKeys.ORDER_ITEM_NOTE_HINT).tr(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey[100],
                              width: 1,
                              style: BorderStyle.solid,
                            )),
                        focusColor: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getItemSizesAsWidgetList() {
    List<Widget> sizesList = [];
    List<ProductAddOn> sizeList = widget.orderItemViewModel.itemViewModel.sizes;

    for (int i = 0; i < sizeList.length; i++) {
      sizesList.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2),
          child: SizedBox(
            height: 40,
            child: RadioButtonListTile(
              key: GlobalKey(),
              dense: false,
              title: Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(sizeList[i].name , key: Key(sizeList[i].name),),
                      Text(getPriceString(sizeList[i].price)),
                    ],
                  ),
                ),
              ),
              value: sizeList[i],
              groupValue: selectedSize,
              activeColor: Colors.grey[900],
              onChanged: (val) {
                selectedSize = val;
                widget.onSizeSelected(val, widget.itemIndex);
                setState(() {});
                _reloadStream.sink.add(null);
              },
            ),
          ),
        ),
      );
    }
    return sizesList;
  }
  getCheckBoxListView(List<ProductAddOn> productExtras) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: productExtras.length,
        itemBuilder: (context, index) {
          return CustomizedCheckboxListTile(
              key: Key(productExtras[index].name),
            activeColor: Colors.grey[900],
            dense: false,
            title: Padding(
              padding: const EdgeInsetsDirectional.only(start: 2.0,end: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    productExtras[index].name,
                    style: TextStyle(
                      color: Colors.black ,
                    ),
                  ),
                  Text(
                    getPriceString(
                        productExtras[index].price),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            value: itemExtras.contains(productExtras[index]),
            selected: itemExtras.contains(productExtras[index]),
            onChanged: (value) {
              itemExtras.contains(productExtras[index]) ?
              itemExtras.remove(productExtras[index]) : itemExtras.add(productExtras[index]);
              widget.onExtraUpdate(itemExtras , widget.itemIndex);
              setState(() {});
              return;
            }
          );
        },
      ),
    );
  }
  getPriceString(double itemPrice) {


    if (itemPrice == null || itemPrice == 0)
      return '';
    else
      return '$itemPrice ${widget.currencyName ?? ''}';
  }


  @override
  void dispose() {
    _reloadStream.close();
    super.dispose();
  }

  Widget getExtrasAsList({String appLocale , String menuLocal}){
    return Visibility(
      visible:
      widget.orderItemViewModel.itemViewModel.extras != null &&
      widget.orderItemViewModel.itemViewModel.extras.length > 0,

      child: ConfigurableExpansionTile(
        initiallyExpanded: true,
        animatedWidgetFollowingHeader: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.5),
          child: Icon(
            Icons.arrow_drop_down,
            size: 25,
          ),
        ),
        headerExpanded: HelperWidget.resolveDirectionality(
            child: Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          (LocalKeys.EXTRAS_LABEL).tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            locale: appLocale,
            context: context),
        header: HelperWidget.resolveDirectionality(
            child: Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          (LocalKeys.EXTRAS_LABEL).tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            locale: appLocale,
            context: context),
        children: [
          HelperWidget.resolveDirectionality(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getCheckBoxListView(widget.orderItemViewModel.itemViewModel.extras)
                ],
              ),
              locale: menuLocal,
              context: context),
        ],
      ),
    );
  }


}
