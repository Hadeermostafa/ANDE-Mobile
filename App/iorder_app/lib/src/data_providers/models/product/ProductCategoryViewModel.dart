import 'package:ande_app/src/data_providers/models/product/ProductListViewModel.dart';
import 'package:ande_app/src/utilities/ApiParseKeys.dart';
class ProductCategoryViewModel {
  var categoryId, categoryName , categoryImage;
  List<ProductListViewModel> categoryProducts = List<ProductListViewModel>();

  ProductCategoryViewModel({this.categoryId, this.categoryImage , this.categoryName , this.categoryProducts});


  static List<ProductCategoryViewModel> fromListJson(List<dynamic> categoriesList){
  List<ProductCategoryViewModel> categories = List<ProductCategoryViewModel>();
  if(categoriesList != null && categoriesList is List){
    for(int i = 0 ; i < categoriesList.length ; i++){
      categories.add(fromJson(categoriesList[i]));
    }
  }
    return categories;
  }

  static ProductCategoryViewModel fromJson(v) {
    List<ProductListViewModel> associatedProducts = List<ProductListViewModel>();
    associatedProducts =  ProductListViewModel.fromListJson(v[ApiParseKeys.RESTAURANT_MENU_AVAILABLE_ITEMS]) ?? [];
    return ProductCategoryViewModel(
      categoryProducts: associatedProducts,
      categoryId: (v[ApiParseKeys.CATEGORY_ID] ?? '').toString(),
      categoryName: (v[ApiParseKeys.CATEGORY_NAME] ?? '').toString(),
      categoryImage: (v[ApiParseKeys.CATEGORY_IMAGE] ?? '').toString(),
    );
  }
}


