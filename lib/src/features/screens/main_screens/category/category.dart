import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class Category {
  final String title;
  final String imagePath;
  final String number;
  final List<String> subcategoryTitles;

  Category({
    required this.title,
    required this.imagePath,
    required this.number,
    required this.subcategoryTitles,
  });
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      CollectionReference collection =
          FirebaseFirestore.instance.collection('categories');
      QuerySnapshot querySnapshot = await collection.get();

      List<Category> fetchedCategories = [];

      for (var doc in querySnapshot.docs) {
        List<String> subcategoryTitles = await fetchSubcategories(doc.id);
        String imagePath = '';
        if (subcategoryTitles.isNotEmpty) {
          final subcategoryData =
              await fetchSubcategoryData(doc.id, subcategoryTitles.first);
          imagePath = subcategoryData['image_path'] ?? '';
        }

        fetchedCategories.add(
          Category(
            title: doc.id,
            imagePath: imagePath,
            number:
                '0/${subcategoryTitles.length}', // Use length instead of maxLength
            subcategoryTitles: subcategoryTitles,
          ),
        );
      }

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<List<String>> fetchSubcategories(String docId) async {
    List<String> subcategoryTitles = [];

    try {
      CollectionReference subcollection = FirebaseFirestore.instance
          .collection('categories')
          .doc(docId)
          .collection('subcategories');
      QuerySnapshot subcollectionSnapshot = await subcollection.get();

      for (var subDoc in subcollectionSnapshot.docs) {
        subcategoryTitles.add(subDoc.id);
      }
    } catch (e) {
      print("Error fetching subcategories: $e");
    }

    return subcategoryTitles;
  }

  Future<String> fetchSubcategoryImage(
      String categoryId, String subcategoryId) async {
    try {
      DocumentSnapshot subcategoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('subcategories')
          .doc(subcategoryId)
          .get();

      // Safely cast data to Map<String, dynamic> before accessing
      final data = subcategoryDoc.data() as Map<String, dynamic>?;

      // Return the image path if it exists, else return an empty string
      return data?['image_path'] ?? '';
    } catch (e) {
      print("Error fetching subcategory image: $e");
      return '';
    }
  }

  Future<Map<String, dynamic>> fetchSubcategoryData(
      String categoryId, String subcategoryId) async {
    try {
      DocumentSnapshot subcategoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('subcategories')
          .doc(subcategoryId)
          .get();

      return (subcategoryDoc.data() as Map<String, dynamic>?) ?? {};
    } catch (e) {
      print("Error fetching subcategory data: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _categoryContainer(categories),
    );
  }

  Widget _categoryContainer(List<Category> categories) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 10, 0, 0),
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _categoryCard(categories[index]);
        },
      ),
    );
  }

  Widget _categoryCard(Category category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Text(
                capitalizeFirstLetter(category.title),
                style: const TextStyle(
                  fontFamily: AppFonts.feb,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 15),
              Text(category.number),
            ],
          ),
        ),
        _categorySubcollection(category),
      ],
    );
  }

  Widget _categorySubcollection(Category category) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...category.subcategoryTitles.map((title) {
                String imagePath = ''; // Placeholder for image path
    
                // Fetch image for the subcategory
                fetchSubcategoryImage(category.title, title).then((image) {
                  setState(() {
                    imagePath = image; // Update the imagePath variable
                  });
                });
    
                return _categoryImageWithTitle(
                  imagePath.isNotEmpty
                      ? imagePath
                      : 'assets/images/monkey.png',
                  title,
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subcategoryWidget(String title) {
    return Text(
      title,
      style: const TextStyle(fontFamily: AppFonts.feb, fontSize: 14),
    );
  }

  Widget _categoryImageWithTitle(String imagePath, String title) {
    return Container(
      width: 150,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(right: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.network(
                imagePath.isNotEmpty ? imagePath : 'assets/images/monkey.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              capitalizeFirstLetter(title),
              style: const TextStyle(
                fontFamily: AppFonts.fcr,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
