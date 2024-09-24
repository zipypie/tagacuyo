import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/settings/setting_dialog.dart';
import 'package:taga_cuyo/src/features/services/preferences_storage.dart';

class ProfileScreenPage extends StatefulWidget {
  final String uid;

  const ProfileScreenPage({super.key, required this.uid});

  @override
  State<ProfileScreenPage> createState() => _ProfileScreenPageState();
}

class _ProfileScreenPageState extends State<ProfileScreenPage> {
  String name = 'Loading...';
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    print("Fetching user data for UID: ${widget.uid}");
    
    DocumentSnapshot? userDoc = await userService.getUserById(widget.uid);
    
    if (userDoc != null && userDoc.exists) {
      setState(() {
        String firstName = userDoc['firstname'] ?? '';
        String lastName = userDoc['lastname'] ?? '';
        name = '${capitalize(firstName)} ${capitalize(lastName)}';
      });
    } else {
      setState(() {
        name = 'User not found';
      });
      print("No document found for UID: ${widget.uid}");
    }
  }

  String capitalize(String input) {
    if (input.isEmpty) return '';
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              height: height / 7,
              color: Colors.lightBlue[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.lightBlue,
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: AppFonts.lilitaOne,
                                color: AppColors.titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/setting.png',
                      height: 30,
                    ),
                    onPressed: () {
                      showSettingsDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Progress Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Progreso',
                      style: TextStyle(
                        fontFamily: AppFonts.kanitLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildProgressItem(
                    icon: Image.asset('assets/icons/progress_1.png', width: 30, height: 30),
                    label: 'Natapos na Aralin',
                    value: '5',
                  ),
                  _buildProgressItem(
                    icon: Image.asset('assets/icons/progress_2.png', width: 30, height: 30),
                    label: 'Natapos na Kategorya',
                    value: '13',
                  ),
                  _buildProgressItem(
                    icon: Image.asset('assets/icons/progress_3.png', width: 30, height: 30),
                    label: 'Minuto ng pag-aaral',
                    value: '43',
                  ),
                  _buildProgressItem(
                    icon: Image.asset('assets/icons/progress_4.png', width: 30, height: 30),
                    label: 'Bilang ng araw ng pagaaral',
                    value: '12',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.lightBlue.withOpacity(0.2),
                child: icon,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppFonts.kanitLight,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.kanitLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
