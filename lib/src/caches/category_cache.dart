// caches/category_cache.dart
import 'package:taga_cuyo/src/features/screens/main_screens/category/category.dart';

class CategoryCache {
  static final CategoryCache _instance = CategoryCache._internal();
  factory CategoryCache() => _instance;

  List<Category> categories = [];
  bool isDataFetched = false;

  CategoryCache._internal();
}
