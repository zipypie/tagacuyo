// models/category.dart

class Category {
  final String id;
  final String imagePath;
  final List<Subcategory> subcategories;

  Category({
    required this.id,
    required this.imagePath,
    required this.subcategories,
  });
}

class Subcategory {
  final String id;
  final String name;
  final String imagePath;
  final List<String> words;

  Subcategory({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.words,
  });
}
