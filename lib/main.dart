import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taga_cuyo/src/features/services/auth_wrapper.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_bloc.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';
import 'package:taga_cuyo/src/features/utils/user_session_manager.dart'; 

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

class MyApp extends StatefulWidget { // Change to StatefulWidget to manage lifecycle
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late UserService userService; // UserService instance
  late UserSessionManager userSessionManager; // UserSessionManager instance

  @override
  void initState() {
    super.initState();
    userService = UserService(); // Instantiate UserService
    userSessionManager = UserSessionManager(userService); // Instantiate UserSessionManager
  }

  @override
  void dispose() {
    userSessionManager.dispose(); // Dispose the session manager when the app is closed
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
