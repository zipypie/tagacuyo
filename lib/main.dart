import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taga_cuyo/src/features/services/auth_wrapper.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart'; // Import your UserService
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_bloc.dart'; // Import ProfileBloc

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => UserService(), // Provide UserService here
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
