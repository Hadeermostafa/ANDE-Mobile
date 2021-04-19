import 'package:ande_app/src/data_providers/models/OrderItemViewModel.dart';
import 'package:ande_app/src/ui/list_tiles/ProductCustomizationClosedStateTile.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DeleteItemsPopup extends StatefulWidget {
  final Function onDeleteItem;
  final String restaurantCurrency;
  final List<OrderItemViewModel> itemsList;

  DeleteItemsPopup(this.restaurantCurrency,
      {this.onDeleteItem, this.itemsList});

  @override
  _DeleteItemsPopupState createState() => _DeleteItemsPopupState();
}

class _DeleteItemsPopupState extends State<DeleteItemsPopup> {
  List<OrderItemViewModel> itemsList = [];

  void onNewDeleteClick(int index) {
    if (index > -1 && index < itemsList.length)
      itemsList.removeAt(index);
  }

  void copyItemsList() {
    for(int i = 0; i < widget.itemsList.length; i++) {
      itemsList.add(widget.itemsList[i]);
    }
  }

  @override
  void initState() {
    copyItemsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 2,
      actions: <Widget>[
        ButtonTheme(
          height: 60,
          minWidth: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 0),
              onPressed: () {
                Navigator.of(context).pop(itemsList);
              },
              color: Colors.grey[800],
              child: Text(
                LocalKeys.CONFIRM_LABEL,
                textScaleFactor: 1,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ).tr(),
            ),
          ),
        ),
      ],
      content: Builder(
        builder: (context) {
          return Container(
            child: SizedBox(
                child: Scaffold(
                    backgroundColor: Colors.white,
                    body: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: itemsList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ProductCustomizationClosedStateTile(
                          orderItemViewModel: itemsList[index],
                          onItemRemoveClicked: (index) {
                            onNewDeleteClick(index);
                            setState(() {});
                          },
                          shouldAnimate: true,
                          itemIndex: index,
                          onItemClicked: () {},
                        );
                      },
                    )),
              ),
          );
        },
      ),
      title: Stack(
        children: [
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: 0.0,
            top: 0.0,
            bottom: 0.0,
            child: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.close,
                  size: 22.5,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          Center(
            child: Text(
              (LocalKeys.DELETE_LABEL).tr(),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
