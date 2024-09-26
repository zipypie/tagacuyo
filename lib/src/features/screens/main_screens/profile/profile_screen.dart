import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/account/change_password_page.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/feedback/feedback.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/logout/logout.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_bloc.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_event.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_state.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart'; // Ensure to import UserService

class ProfileScreen extends StatelessWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        RepositoryProvider.of<UserService>(context),
      )..add(FetchUserProfile(uid)),
      child: Scaffold(
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(state.name, state.dateJoined),
                    const SizedBox(height: 20),
                    _buildProgressSection(
                      context,
                      lessonsProgress: state.lessonsProgress,
                      categoriesProgress: state.categoriesProgress,
                      minutesProgress: state.minutesProgress,
                      daysProgress: state.daysProgress,
                      streakProgress: state.streakProgress,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileOptions(context),
                  ],
                ),
              );
            } else if (state is ProfileError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }

// Header Section
Widget _buildHeader(String name, String dateJoined) {
  return Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.lightBlue[100],
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 20.0), // Add left padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70, // Width of the circular background
            height: 70, // Height of the circular background
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 21, 195, 254), // Background color of the circle
            ),
            child: const Center(
              child: Icon(
                Icons.person, // You can change this icon if you prefer a different one
                size: 40, // Adjust the size of the icon
                color: AppColors.titleColor, // Change the color if needed
              ),
            ),
          ),
          const SizedBox(width: 10), // Space between the icon and text
          Expanded( // Use Expanded to allow text to take remaining space
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titleColor,
                  ),
                ),
                Text(
                  'Joined: $dateJoined',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  // Progress Section
  Widget _buildProgressSection(BuildContext context,
      {required int lessonsProgress,
      required int categoriesProgress,
      required int minutesProgress,
      required int daysProgress,
      required int streakProgress}) {
    final halfScreenWidth = (MediaQuery.of(context).size.width * 0.4).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Iyong Progresso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 15,
            children: [
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_2.png', width: 30, height: 30),
                label: 'Aralin',
                value: lessonsProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_3.png', width: 30, height: 30),
                label: 'Kategorya',
                value: categoriesProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_4.png', width: 30, height: 30),
                label: 'Minuto',
                value: minutesProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_5.png', width: 30, height: 30),
                label: 'Araw',
                value: daysProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_6.png', width: 30, height: 30),
                label: 'Streak',
                value: streakProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Progress Item Widget
  Widget _buildProgressItem({
    required BuildContext context,
    required Image icon,
    required String label,
    required String value,
    required double maxWidth,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: maxWidth,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(2, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Profile Options
  Widget _buildProfileOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              // Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Magpalit ng Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_center),
            title: const Text('Magbigay katugunan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const LogoutScreen();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
