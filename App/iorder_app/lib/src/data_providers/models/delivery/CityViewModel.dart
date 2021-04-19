

class RegionViewModel {
  int regionId;
  String regionName;
  List<AreaViewModel> areas = List();

  @override
  String toString() {
    return 'RegionViewModel{regionId: $regionId, regionName: $regionName, areas: $areas}';
  }

  RegionViewModel({this.regionName, this.regionId, this.areas});

  static List<RegionViewModel> fromListJson(List<dynamic> regionListJson) {
    List<RegionViewModel> regionList = List();
    for (int i = 0; i < regionListJson.length; i++) {
      RegionViewModel city = RegionViewModel.fromJson(regionListJson[i]);
      regionList.add(city);
    }
    return regionList;
  }

  static RegionViewModel fromJson(Map<String, dynamic> city) {
    return RegionViewModel(
      regionName: city[RegionViewModelJsonKeys.REGION_NAME],
      regionId: city[RegionViewModelJsonKeys.REGION_ID],
      areas: city[RegionViewModelJsonKeys.REGION_AREAS] != null ? AreaViewModel.fromListJson(city[RegionViewModelJsonKeys.REGION_AREAS]) : null,
    );
  }

  Map<String,dynamic> toJson() {
    List<Map> regions = this.areas != null ? this.areas.map((e) => e.toJson()).toList() : null;
    return {
      RegionViewModelJsonKeys.REGION_ID: this.regionId,
      RegionViewModelJsonKeys.REGION_NAME: this.regionName,
      RegionViewModelJsonKeys.REGION_AREAS: regions,
    };
  }
}

class RegionViewModelJsonKeys {
  static const String REGION_NAME = 'name';
  static const String REGION_ID = 'id';
  static const String REGION_AREAS = 'areas';
}

class AreaViewModel {
  int areaId;
  String areaName;
  AreaViewModel({this.areaName, this.areaId});
  static List<AreaViewModel> fromListJson(List<dynamic> regionsListJson) {
    List<AreaViewModel> regionsList = List();
    for (int i = 0; i < regionsListJson.length; i++) {
      regionsList.add(fromJson(regionsListJson[i]));
    }
    return regionsList;
  }

  static AreaViewModel fromJson(Map<String, dynamic> area) {
    return AreaViewModel(
      areaName: area[AreaViewModelJsonKeys.AREA_NAME],
      areaId: area[AreaViewModelJsonKeys.AREA_ID],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      AreaViewModelJsonKeys.AREA_ID: areaId,
      AreaViewModelJsonKeys.AREA_NAME: areaName,
    };
  }

  @override
  String toString() =>
      'AreaViewModel {areaId: $areaId, areaName: $areaName}';
}

class AreaViewModelJsonKeys {
  static const AREA_NAME = 'name';
  static const AREA_ID = 'id';
}
