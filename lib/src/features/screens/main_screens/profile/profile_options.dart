import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/change_password/change_password_page.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/feedback/feedback.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/logout/logout.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/support/submit_ticket.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/update_profile/update_profile.dart';

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          // Settings button to open dropdown
          PopupMenuButton<String>(
            color: AppColors.primaryBackground,
            onSelected: (String value) {
              // Handle the selected option
              switch (value) {
                case 'Profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UpdateProfileScreen()),
                  );
                  break;
                case 'Magpalit ng Password':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen()),
                  );
                  break;
                case 'Magbigay katugunan':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackScreen()),
                  );
                case 'Magsumite ng ticket':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SupportTicketForm()),
                  );
                  break;
                case 'Logout':
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const LogoutScreen();
                    },
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Profile',
                child: ListTile(
                  leading: Icon(Icons.person_2_rounded),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Magpalit ng Password',
                child: ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Magpalit ng Password'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Magbigay katugunan',
                child: ListTile(
                  leading: Icon(Icons.help_center),
                  title: Text('Magbigay katugunan'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Magsumite ng ticket',
                child: ListTile(
                  leading: Icon(Icons.support_agent_outlined),
                  title: Text('Magsumite ng ticket'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
            child: Image.asset(
              'assets/icons/setting.png',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}
