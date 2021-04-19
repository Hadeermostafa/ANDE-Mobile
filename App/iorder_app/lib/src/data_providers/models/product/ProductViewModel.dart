import 'package:ande_app/src/utilities/HelperFunctions.dart';

class ProductViewModel {
  int id;
  String name;
  String description;
  bool isSpicy;
  List<String> images;
  List<ProductAddOn> sizes;
  List<ProductAddOn> extras;
  List<CustomUrl> media;

  ProductViewModel(
      {this.id,
      this.name,
      this.description,
      this.isSpicy,
      this.images,
      this.sizes,
      this.extras,
      this.media});

  static ProductViewModel fromJson(json) {



    List<CustomUrl> _media = [];
    List<ProductAddOn> _sizes;
    List<String> _mediaSources = [];
    json[ProductViewModelJsonKeys.PRODUCT_IMAGES].forEach((element){
      _mediaSources.add(element);
    });
    _mediaSources.forEach((element) {
      if (element.endsWith('.png') || element.endsWith('.jpg') || element.endsWith('.jpeg')) {
        _media.add(CustomUrl(url: element, source: MEDIA_SOURCE.IMAGE));
      }
      else if (element.contains('youtube')) {
        _media.add(CustomUrl(url: element, source: MEDIA_SOURCE.YOUTUBE));
      }
      else {
        _media.add(CustomUrl(url: element, source: MEDIA_SOURCE.SERVER));
      }
    });
    if (json[ProductViewModelJsonKeys.PRODUCT_SIZES] != null) {
      _sizes = new List<ProductAddOn>();
      json[ProductViewModelJsonKeys.PRODUCT_SIZES].forEach((v) {
        _sizes.add(ProductAddOn.fromJson(v));
      });
    }
    List<ProductAddOn> _extras;
    if (json[ProductViewModelJsonKeys.PRODUCT_EXTRAS] != null) {
      _extras = new List<ProductAddOn>();
      json[ProductViewModelJsonKeys.PRODUCT_EXTRAS].forEach((v) {
        _extras.add(ProductAddOn.fromJson(v));
      });
    }
    return ProductViewModel(
      id: json[ProductViewModelJsonKeys.PRODUCT_ID],
      name: json[ProductViewModelJsonKeys.PRODUCT_NAME],
      description: json[ProductViewModelJsonKeys.PRODUCT_DESCRIPTION],
      isSpicy: json[ProductViewModelJsonKeys.PRODUCT_IS_SPICY] == 0 ? false : true,
      images: json[ProductViewModelJsonKeys.PRODUCT_IMAGES].cast<String>(),
      sizes: _sizes,
      extras: _extras,
      media: _media
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[ProductViewModelJsonKeys.PRODUCT_ID] = this.id;
    data[ProductViewModelJsonKeys.PRODUCT_NAME] = this.name;
    data[ProductViewModelJsonKeys.PRODUCT_DESCRIPTION] = this.description;
    data[ProductViewModelJsonKeys.PRODUCT_IS_SPICY] = this.isSpicy;
    data[ProductViewModelJsonKeys.PRODUCT_IMAGES] = this.images;
    if (this.sizes != null) {
      data[ProductViewModelJsonKeys.PRODUCT_SIZES] = this.sizes.map((v) => v.toJson()).toList();
    }
    if (this.extras != null) {
      data[ProductViewModelJsonKeys.PRODUCT_EXTRAS] = this.extras.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

enum MEDIA_SOURCE { YOUTUBE, SERVER, IMAGE }

class CustomUrl {
  String url;
  MEDIA_SOURCE source;
  CustomUrl({this.url, this.source});
}

class ProductAddOn {
  int id;
  String name;
  double price;


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAddOn &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode;

  @override
  String toString() {
    return 'ProductAddOn{id: $id, name: $name, price: $price}';
  }

  ProductAddOn({this.id, this.name, this.price});

  ProductAddOn.fromJson(Map<String, dynamic> json) {


  if(json.containsKey('extra_info')){
    json = json['extra_info'];
  }
    id = json[ProductAddOnModelJsonKeys.PRODUCT_ADD_ON_ID];
    name = json[ProductAddOnModelJsonKeys.PRODUCT_ADD_ON_NAME];
    price = ParseHelper.parseNumber(json[ProductAddOnModelJsonKeys.PRODUCT_ADD_ON_PRICE] ,toDouble: true);
  }

  static List<ProductAddOn> fromListJson(List<dynamic> productAddons){



    List<ProductAddOn> addOns = List<ProductAddOn>();

    if(productAddons != null && productAddons is List) {
      for (int i = 0; i < productAddons.length; i++) {
        addOns.add(ProductAddOn.fromJson(productAddons[i]));
      }
    }

    return addOns;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[ProductAddOnModelJsonKeys.PRODUCT_ADD_ON_ID] = this.id;
    data[ProductAddOnModelJsonKeys.PRODUCT_ADD_ON_NAME] = this.name;
    data[ProductAddOnModelJsonKeys.PRODUCT_ADD_ON_PRICE] = this.price;
    return data;
  }

  ProductAddOn deepCopy() {
    return ProductAddOn(id: this.id, name: this.name,price: this.price);
  }
}

class ProductAddOnModelJsonKeys {
  static const String PRODUCT_ADD_ON_ID = 'id';
  static const String PRODUCT_ADD_ON_NAME = 'name';
  static const String PRODUCT_ADD_ON_PRICE = 'price';
}

class ProductViewModelJsonKeys {
  static const String PRODUCT_ID = 'id';
  static const String PRODUCT_NAME = 'name';
  static const String PRODUCT_DESCRIPTION = 'description';
  static const String PRODUCT_IS_SPICY = 'spicy';
  static const String PRODUCT_IMAGES = 'images';
  static const String PRODUCT_SIZES = 'sizes';
  static const String PRODUCT_EXTRAS = 'extras';
}
