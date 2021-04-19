import 'package:ande_app/src/data_providers/models/delivery/CityViewModel.dart';
import 'package:ande_app/src/data_providers/models/delivery/DeliveryArea.dart';
import 'package:ande_app/src/resources/external_resource/RadioButtonListTile.dart';
import 'package:ande_app/src/ui/widgets/AndeAppbar.dart';
import 'package:ande_app/src/ui/widgets/HelperWidgets.dart';
import 'package:ande_app/src/utilities/LocalKeys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RegionPickerScreen extends StatefulWidget {
  final List<AreaViewModel> elements;
  final List<DeliveryArea> restaurantCities;
  final AreaViewModel chosenRegion;
  RegionPickerScreen({this.elements, this.restaurantCities, this.chosenRegion});
  @override
  _RegionPickerScreenState createState() => _RegionPickerScreenState();
}

class _RegionPickerScreenState extends State<RegionPickerScreen> {
  List<AreaViewModel> systemElements = List<AreaViewModel>(),
      elements = List<AreaViewModel>();
  List<DeliveryArea> restaurantCities;
  AreaViewModel _previouslySelectedRegion;
  AreaViewModel _regionViewModel;

  @override
  void initState() {
    super.initState();

    this.systemElements = widget.elements;
    this.restaurantCities = widget.restaurantCities;
    if (widget.chosenRegion != null) {
      _previouslySelectedRegion = widget.chosenRegion;
    } else {
      _previouslySelectedRegion = AreaViewModel()..areaId = -1;
    }
  }

  void _checkForPreviousSelection() {
    if (_previouslySelectedRegion != null && widget.elements != null && widget.elements.length > 0) {
      for (int i = 0; i < widget.elements.length; i++) {
        if (_previouslySelectedRegion.areaId == widget.elements[i].areaId) {
          _regionViewModel = _previouslySelectedRegion;
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (restaurantCities != null) {
      for (int i = 0; i < systemElements.length; i++) {
        if (restaurantCities.indexWhere(
                (element) => (systemElements[i].areaId == element.regionId)) >
            -1) {
          elements.add(systemElements[i]);
        }
      }
    }
    _checkForPreviousSelection();
    return Scaffold(
      appBar: AndeAppbar(
        screenTitle: (LocalKeys.SELECT_REGION).tr(),
        hasBackButton:true,
      ),
      body: Column(
        children: <Widget>[
          HelperWidget.verticalSpacer(heightVal: 15),
          Expanded(
            child: ListView.builder(
                itemCount: widget.elements.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: RadioButtonListTile<AreaViewModel>(
                      selected: widget.elements[index].areaId == _previouslySelectedRegion.areaId,
                      groupValue: _regionViewModel,
                      dense: false,
                      activeColor: Colors.black,
                      title: Expanded(
                          child: Text(widget.elements[index].areaName)),
                      onChanged: (AreaViewModel value) {
                        setState(() {
                          _regionViewModel = value;
                        });
                        Navigator.pop(context, _regionViewModel);
                      },
                      value: widget.elements[index],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
