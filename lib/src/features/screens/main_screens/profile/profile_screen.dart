import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:taga_cuyo/src/features/common_widgets/loading_animation/profile_loading.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_bloc.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_event.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_options.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_state.dart';

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
            return const ProfileLoadingShimmer();
          } else if (state is ProfileLoaded) {
            return SingleChildScrollView(
              child: Container(
                color: AppColors.primaryBackground.withOpacity(0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(state.name, state.dateJoined, state.profileImageUrl),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: _buildProgressSection(
                        context,
                        lessonsProgress: state.lessonsProgress,
                        categoriesProgress: state.categoriesProgress,
                        minutesProgress: state.minutesProgress,
                        daysProgress: state.daysProgress,
                        streakProgress: state.streakProgress,
                        longestStreakProgress: state.longestStreakProgress,
                      ),
                    ),
                  ],
                ),
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
    // Parse the dateJoined string to DateTime
    DateTime dateTime = DateTime.parse(dateJoined); // Assuming dateJoined is in ISO format
    String formattedDate = DateFormat('MMMM d, y').format(dateTime); // Format the date

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: const Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 0.1, // Bottom border thickness
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color with opacity
            offset: const Offset(0, 2), // Horizontal and vertical shadow offset
            blurRadius: 4.0, // How blurry the shadow should be
            spreadRadius: 0.0, // How much the shadow should spread
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  // Add this part for the border
                  color: AppColors.primary, // Set your desired border color
                  width: 5.0, // Set the thickness of the border
                ),
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
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleColor,
                    ),
                  ),
                  Text(
                    'Sumali noong: $formattedDate', // Use the formatted date
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 25, 25, 25),
                  child: ProfileOptions(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // The rest of your ProfileScreen class remains unchanged.


  // Progress Section
  Widget _buildProgressSection(
    BuildContext context, {
    required int lessonsProgress,
    required int categoriesProgress,
    required int minutesProgress,
    required int daysProgress,
    required int streakProgress,
    required int longestStreakProgress,
  }) {
    final halfScreenWidth = MediaQuery.of(context).size.width * 0.9;
    const double progressIconSize = 40.0; // Define image size once

    return Padding(
      padding: const EdgeInsets.fromLTRB(35, 30, 35, 30),
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
                icon: Image.asset('assets/icons/progress_1.png',
                    width: progressIconSize, height: progressIconSize),
                label: 'Natapos na Aralin',
                value: lessonsProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_2.png',
                    width: progressIconSize, height: progressIconSize),
                label: 'Natapos na Kategorya',
                value: categoriesProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_3.png',
                    width: progressIconSize, height: progressIconSize),
                label: 'Minuto ng pag-aaral',
                value: minutesProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_4.png',
                    width: progressIconSize, height: progressIconSize),
                label: 'Bilang ng araw ng pagaaral',
                value: daysProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_5.png',
                    width: progressIconSize, height: progressIconSize),
                label: 'Bilang ng araw na sunod sunod',
                value: streakProgress.toString(),
                maxWidth: halfScreenWidth,
              ),
              _buildProgressItem(
                context: context,
                icon: Image.asset('assets/icons/progress_6.png',
                    width: progressIconSize, height: progressIconSize),
                label: 'Pinakamatagal na sunod sunod',
                value: longestStreakProgress.toString(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;

        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: isSmallScreen ? 14 : 18),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }


}
