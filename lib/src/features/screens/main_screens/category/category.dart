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

  // Convert Category instance to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'subcategories': subcategories.map((subcategory) => subcategory.toMap()).toList(),
    };
  }

  // Convert Map to Category instance
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      imagePath: map['image_path'],
      subcategories: List<Subcategory>.from(map['subcategories']?.map((x) => Subcategory.fromMap(x))),
    );
  }
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

  // Convert Subcategory instance to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subcategory_name': name,
      'image_path': imagePath,
      'words': words,
    };
  }

  // Convert Map to Subcategory instance
  factory Subcategory.fromMap(Map<String, dynamic> map) {
    return Subcategory(
      id: map['id'],
      name: map['subcategory_name'],
      imagePath: map['image_path'],
      words: List<String>.from(map['words']),
    );
  }
}
