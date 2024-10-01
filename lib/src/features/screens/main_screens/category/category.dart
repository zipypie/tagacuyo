import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/category_quiz.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';

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
  final AuthService _authService = AuthService(); // Create an instance of AuthService
  String? userId; // Variable to hold the user ID
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
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _categoryCard(categories[index]);
      },
    );
  }

  Widget _categoryCard(Category category) {
    return Container(
      height: MediaQuery.of(context).size.height * 1 / 3.61,
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(width: 3, color: Color.fromARGB(255, 96, 96, 96)),
      )),
      child: Column(
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
                    fontSize: 21,
                  ),
                ),
                const SizedBox(width: 15),
                Text(category.number),
              ],
            ),
          ),
          _categorySubcollection(category),
        ],
      ),
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
                          return _categoryImageWithTitle(imageUrl, title, category); // Pass category object
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


 Widget _categoryImageWithTitle(
    String imagePath, String title, Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NextQuizScreen(
              title: category.title, // Pass the category title
              subcategoryTitle: title, // Pass the selected subcategory title
              currentWord: title, // Pass the current word for fetching the next one
              userId: userId ?? '', // Pass the user ID (default to empty string if null)
            ),
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 6, color: AppColors.accentColor),
                borderRadius: BorderRadius.circular(20),
              ),
              width: 120,
              height: 120,
              child: imagePath.isNotEmpty
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/monkey.png',
                            fit: BoxFit.cover);
                      },
                    )
                  : Image.asset('assets/images/monkey.png', fit: BoxFit.cover),
            ),
            const SizedBox(height: 5),
            Text(
              capitalizeFirstLetter(title),
              style: const TextStyle(
                fontFamily: AppFonts.fcr,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
