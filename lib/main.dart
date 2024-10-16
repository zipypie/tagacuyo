import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/home/dialogSurvey/dialog_survey.dart';
import 'package:taga_cuyo/src/features/services/auth_wrapper.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/services/day_count.dart';
import 'package:taga_cuyo/src/features/services/streak_count.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_bloc.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';
import 'package:taga_cuyo/src/features/services/user_session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    await Hive.openBox('images'); // Open Hive box for storing images

    // Activate Firebase App Check for both Android and iOS
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  } catch (e) {
    Logger.log('Error initializing Firebase or Hive: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late UserService userService;
  late UserSessionManager userSessionManager;
  late StreakCounterService streakCounterService;
  late AuthService authService;
  bool _dialogShown = false; // Flag to prevent multiple dialogs

  @override
  void initState() {
    super.initState();
    userService = UserService();
    userSessionManager = UserSessionManager(userService);
    DayCounterService dayCounterService = DayCounterService();
    dayCounterService.updateDayInSession();

    streakCounterService = StreakCounterService();
    streakCounterService.updateStreak();

    authService = AuthService(); // Initialize AuthService

    _checkAndShowSurveyDialog(); // Check and show dialog
  }

 Future<void> _checkAndShowSurveyDialog() async {
  String? uid = authService.getUserId(); // Get the user's UID

  if (uid != null) {
    Logger.log("Current User UID: $uid"); // Debug Logger.log

    final userData = await authService.getUserData();

    // Debugging information
    if (userData == null) {
      Logger.log("User data is null");
      return; // Exit early if userData is null
    } else {
      Logger.log("User data retrieved: ${userData.data()}");
    }

    // Check if the user has completed the survey
    var hasCompletedSurvey = (userData.data() as Map<String, dynamic>)['hasCompletedSurvey'] ?? false;

    if (!hasCompletedSurvey) { // Only show dialog if the survey is not completed
      if (mounted && !_dialogShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SurveyDialog(
                uid: uid,
                onCompleted: () {
                  _dialogShown = false; // Reset the dialogShown flag after survey is completed
                },
              );
            },
          );
          _dialogShown = true; // Ensure the dialog is only shown once
          Logger.log("Showing SurveyDialog for UID: $uid"); // Debug Logger.log
        });
      }
    } else {
      Logger.log("Survey already completed.");
    }
  } else {
    Logger.log("No user is logged in."); // Handle case where no user is logged in
  }
}


  @override
  void dispose() {
    userSessionManager.dispose(); // Dispose session manager
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => userService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ProfileBloc(
              RepositoryProvider.of<UserService>(context),
            ),
          ),
        ],
        child: const MaterialApp(
          title: 'Taga-Cuyo App',
          debugShowCheckedModeBanner: false,
          home: AuthWrapper(),
        ),
      ),
    );
  }
}
