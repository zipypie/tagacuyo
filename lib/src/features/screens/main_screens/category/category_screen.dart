// screens/category_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/category.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/quiz/category_quiz.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';
import 'package:firebase_storage/firebase_storage.dart';

const String categoriesCollection = 'categories';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with AutomaticKeepAliveClientMixin<CategoryScreen> {
  List<Category> categories = [];
  final AuthService _authService = AuthService();
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserId();
    fetchCategories();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> fetchCurrentUserId() async {
    userId = _authService.getUserId();
    if (userId == null) {
      Logger.log("User is not logged in");
    }
  }

  Future<void> fetchCategories() async {
    try {
      CollectionReference collection =
          FirebaseFirestore.instance.collection(categoriesCollection);
      QuerySnapshot querySnapshot = await collection.get();

      List<Category> fetchedCategories = [];

      for (var doc in querySnapshot.docs) {
        String id = doc.id;
        String imagePath =
            (doc.data() as Map<String, dynamic>?)?['image_path'] ?? '';
        String imageUrl = await fetchImageFromStorage(imagePath);
        List<Subcategory> subcategories = await fetchSubcategories(id);

        Logger.log(
            "Fetched category: $id with ${subcategories.length} subcategories");

        fetchedCategories.add(
          Category(
            id: id,
            imagePath: imageUrl,
            subcategories: subcategories,
          ),
        );
      }

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      Logger.log("Error fetching categories: $e");
    }
  }

  Future<String> fetchImageFromStorage(String imagePath) async {
    try {
      Reference imageRef = FirebaseStorage.instance.refFromURL(imagePath);
      return await imageRef.getDownloadURL();
    } catch (e) {
      Logger.log("Error fetching image from storage: $e");
      return '';
    }
  }

  Future<List<Subcategory>> fetchSubcategories(String categoryId) async {
    List<Subcategory> subcategories = [];
    try {
      CollectionReference subcollection = FirebaseFirestore.instance
          .collection(categoriesCollection)
          .doc(categoryId)
          .collection('subcategories');
      QuerySnapshot subcollectionSnapshot = await subcollection.get();

      for (var subDoc in subcollectionSnapshot.docs) {
        String subcategoryId = subDoc.id;
        Map<String, dynamic> data = subDoc.data() as Map<String, dynamic>;

        String imagePath = (data['image_path'] ?? '');
        String imageUrl = await fetchImageFromStorage(imagePath);
        String name = data['subcategory_name'] ?? '';
        List<String> words = List<String>.from(data['words'] ?? []);

        subcategories.add(
          Subcategory(
            id: subcategoryId,
            name: name,
            imagePath: imageUrl,
            words: words,
          ),
        );
      }
    } catch (e) {
      Logger.log("Error fetching subcategories: $e");
    }
    return subcategories;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  capitalizeFirstLetter(category.id),
                  style: const TextStyle(
                    fontFamily: AppFonts.fcb,
                    fontSize: 21,
                  ),
                ),
                Text(
                  '0/${category.subcategories.length}',
                  style: const TextStyle(
                    fontFamily: AppFonts.fcr,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _subcategoryList(category),
        ],
      ),
    );
  }

  Widget _subcategoryList(Category category) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: category.subcategories.map((subcategory) {
              return _subcategoryImageWithTitle(
                  subcategory.imagePath,
                  capitalizeFirstLetter(subcategory.name),
                  subcategory,
                  category);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _subcategoryImageWithTitle(String imagePath, String title,
      Subcategory subcategory, Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryQuizScreen(
              subcategoryTitle: subcategory.name,
              categoryId: category.id, // Use the category's id
              currentWord: '',
              subcategoryId: subcategory.id,
              userId: userId ?? '',
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
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                              child: Text('Image not available'));
                        },
                      ),
                    )
                  : const Center(child: Text('Image not available')),
            ),
            const SizedBox(height: 5),
            Text(
              title,
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
}
