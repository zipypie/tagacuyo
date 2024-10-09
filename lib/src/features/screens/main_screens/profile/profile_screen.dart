import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/account/change_password_page.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/feedback/feedback.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/logout/logout.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_bloc.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_event.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_state.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/update_profile/update_profile.dart';

class ProfileScreen extends StatelessWidget {
  final String? uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<ProfileBloc>(context);

    // Fetch user profile only if state is ProfileLoading or initial state
    if (profileBloc.state is ProfileLoading || profileBloc.state is ProfileError) {
      profileBloc.add(FetchUserProfile(uid!));
    }

    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(state.name, state.dateJoined, state.profileImageUrl),
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
    );
  }

  // Header Section
  Widget _buildHeader(String name, String dateJoined, String profileImageUrl) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 21, 195, 254),
              ),
              child: ClipOval(
                child: profileImageUrl.isNotEmpty
                  ? Image.network(
                      profileImageUrl,
                      fit: BoxFit.cover,
                      width: 70,
                      height: 70,
                    )
                  : const Center(
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.titleColor,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
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
                    'Sumali noong: $dateJoined',
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
    final halfScreenWidth = MediaQuery.of(context).size.width * 0.4;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 80, 93, 100), 
            width: 1, 
          ),
           top: BorderSide(
            color: Color.fromARGB(255, 80, 93, 100), 
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
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
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 15,
              children: [
                _buildProgressItem(
                  context: context,
                  icon: Image.asset('assets/icons/progress_2.png',
                      width: 30, height: 30),
                  label: 'Aralin',
                  value: lessonsProgress.toString(),
                  maxWidth: halfScreenWidth,
                ),
                _buildProgressItem(
                  context: context,
                  icon: Image.asset('assets/icons/progress_3.png',
                      width: 30, height: 30),
                  label: 'Kategorya',
                  value: categoriesProgress.toString(),
                  maxWidth: halfScreenWidth,
                ),
                _buildProgressItem(
                  context: context,
                  icon: Image.asset('assets/icons/progress_4.png',
                      width: 30, height: 30),
                  label: 'Minuto',
                  value: minutesProgress.toString(),
                  maxWidth: halfScreenWidth,
                ),
                _buildProgressItem(
                  context: context,
                  icon: Image.asset('assets/icons/progress_5.png',
                      width: 30, height: 30),
                  label: 'Araw',
                  value: daysProgress.toString(),
                  maxWidth: halfScreenWidth,
                ),
                _buildProgressItem(
                  context: context,
                  icon: Image.asset('assets/icons/progress_6.png',
                      width: 30, height: 30),
                  label: 'Sunod sunod na araw',
                  value: streakProgress.toString(),
                  maxWidth: halfScreenWidth * 1.4,
                ),
              ],
            ),
          ],
        ),
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
            leading: const Icon(Icons.person_2_rounded),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UpdateProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Magpalit ng Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen()),
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
