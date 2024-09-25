import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/account/change_password_page.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/feedback/feedback.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/logout/logout.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart';
import 'profile_bloc.dart'; // Import the BLoC file
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileScreenPage extends StatelessWidget {
  final String uid;

  const ProfileScreenPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(UserService())..add(FetchUserProfile(uid)),
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is ProfileLoaded) {
                return SingleChildScrollView(
                  // Enable scrolling
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(state.name, state.dateJoined),
                      const SizedBox(height: 20),
                      _buildProgressSection(context), // Progress section
                      const SizedBox(height: 20),
                      _buildProfileOptions(
                          context), // Profile options (e.g., My Profile, Logout)
                    ],
                  ),
                );
              }
              return const Center(child: Text('Unknown State'));
            },
          ),
        ),
      ),
    );
  }

  // Build header section with user info
  Widget _buildHeader(String name, String dateJoined) {
    return Container(
      height: 125, // Adjust this value to change the overall height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue[300]!, Colors.lightBlue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(25, 10, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align to the start
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 70, // Set the height of the box behind the icon
            width: 70, // Set the width of the box behind the icon
            decoration: BoxDecoration(
              color: Colors.lightBlue
                  .withOpacity(0.2), // Optional: change the background color
              shape: BoxShape.circle, // Make it circular
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.lightBlue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            // Wrap user name in Expanded for flexibility
            child: _buildUserName(name, dateJoined),
          ),
        ],
      ),
    );
  }

  // Build user name display with date joined below
  Widget _buildUserName(String name, String dateJoined) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppColors.titleColor,
              ),
              overflow: TextOverflow.ellipsis, // Prevent overflow
              maxLines: 1, // Limit to one line
            ),
          ),
          const SizedBox(height: 4), // Space between name and date joined
          Flexible(
            child: Text(
              'Date Joined: $dateJoined',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.titleColor,
              ),
              overflow: TextOverflow.ellipsis, // Prevent overflow
              maxLines: 1, // Limit to one line
            ),
          ),
        ],
      ),
    );
  }

  // Build progress section with cards
  // Build progress section with cards
// Build progress section with cards
Widget _buildProgressSection(BuildContext context) {
final halfScreenWidth = (MediaQuery.of(context).size.width * 0.4).toDouble(); // Convert to int


  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Overview',
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
              value: '5',
              maxWidth: halfScreenWidth, // Pass the calculated half screen width
            ),
            _buildProgressItem(
              context: context,
              icon: Image.asset('assets/icons/progress_3.png', width: 30, height: 30),
              label: 'Kategorya',
              value: '13',
              maxWidth: halfScreenWidth,
            ),
            _buildProgressItem(
              context: context,
              icon: Image.asset('assets/icons/progress_4.png', width: 30, height: 30),
              label: 'Minuto',
              value: '43',
              maxWidth: halfScreenWidth,
            ),
            _buildProgressItem(
              context: context,
              icon: Image.asset('assets/icons/progress_5.png', width: 30, height: 30),
              label: 'Araw',
              value: '12',
              maxWidth: halfScreenWidth,
            ),
            _buildProgressItem(
              context: context,
              icon: Image.asset('assets/icons/progress_6.png', width: 30, height: 30),
              label: 'Streak',
              value: '7',
              maxWidth: halfScreenWidth,
            ),
          ],
        ),
      ],
    ),
  );
}


  // Build individual progress item
 Widget _buildProgressItem({
  required BuildContext context,
  required Widget icon,
  required String label,
  required String value,
  required double maxWidth, // Pass the max width allowed for each item
}) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: maxWidth, // Each item can expand to this max width
    ),
    child: Container(
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
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.lightBlue.withOpacity(0.2),
            child: icon,
          ),
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
    ),
  );
}

  // Build profile options (My Profile, Change Password, etc.)
  Widget _buildProfileOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ListView(
        shrinkWrap: true, // Allow the ListView to shrink to fit its contents
        physics:
            const NeverScrollableScrollPhysics(), // Prevent independent scrolling
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
                MaterialPageRoute(
                    builder: (context) =>
                        const ChangePasswordScreen()), // Corrected here
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_center),
            title: const Text('Magbigay katugunan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const FeedbackScreen()), // Corrected here
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Show the LogoutScreen dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const LogoutScreen(); // Show the logout confirmation dialog
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
