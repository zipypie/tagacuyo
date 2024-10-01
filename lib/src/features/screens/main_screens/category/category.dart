import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/category_quiz.dart';

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

        fetchedCategories.add(
          Category(
            title: doc.id,
            imagePath: '', // Placeholder for image path
            number: '0/${subcategoryTitles.length}',
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
                  fontFamily: AppFonts.fcb,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 15),
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
                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchSubcategoryData(category.title, title),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Image.asset('assets/images/monkey.png');
                    } else {
                      String imagePath = snapshot.data?['image_path'] ?? '';
                      return FutureBuilder<String>(
                        future: fetchImageFromStorage(imagePath),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (imageSnapshot.hasError) {
                            return Image.asset('assets/images/monkey.png');
                          } else {
                            String imageUrl = imageSnapshot.data ?? 'assets/images/monkey.png';
                            return _categoryImageWithTitle(imageUrl, title, category.title);
                          }
                        },
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
 
  Widget _categoryImageWithTitle(String imagePath, String title, String categoryTitle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoryQuizScreen(),
          ),
        );
      },
      child: SizedBox(
        width: 150,
        height: 150,
        child: Padding(
          padding: const EdgeInsets.only(right: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 100,
                height: 100,
                child: imagePath.isNotEmpty
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/monkey.png', fit: BoxFit.cover);
                        },
                      )
                    : Image.asset('assets/images/monkey.png', fit: BoxFit.cover),
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
      ),
    );
  }

  Future<Map<String, dynamic>> fetchSubcategoryData(String categoryId, String subcategoryId) async {
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

  Future<String> fetchImageFromStorage(String imagePath) async {
    try {
      Reference imageRef = FirebaseStorage.instance.refFromURL(imagePath);
      return await imageRef.getDownloadURL();
    } catch (e) {
      print("Error fetching image from storage: $e");
      return '';
    }
  }
}
