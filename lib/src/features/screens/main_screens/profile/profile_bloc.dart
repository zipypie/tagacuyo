import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserService userService;

  ProfileBloc(this.userService) : super(ProfileLoading()) {
    on<FetchUserProfile>(_onFetchUserProfile);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event, Emitter<ProfileState> emit) async {
  emit(ProfileLoading());
  try {
    // Fetch user document
  final userDoc = await userService.getUserById(event.uid);
  print('User document: ${userDoc?.data()}');

    if (userDoc != null && userDoc.exists) {
      String firstName = userDoc['firstname'] ?? '';
      String lastName = userDoc['lastname'] ?? '';
      String name = '${capitalize(firstName)} ${capitalize(lastName)}';

      // Fetch date joined from Firestore
      Timestamp joinedTimestamp = userDoc['date_joined'] ?? Timestamp.now();
      String dateJoined = joinedTimestamp.toDate().toLocal().toString().split(' ')[0];

      // Fetch user progress document
      final progressDoc = await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(event.uid)
          .get();

      if (progressDoc.exists) {
        // Extract progress data
        int lessonsProgress = progressDoc['lessons'] ?? 0;
        int categoriesProgress = progressDoc['categories'] ?? 0;
        int minutesProgress = progressDoc['minutes'] ?? 0;
        int daysProgress = progressDoc['days'] ?? 0;
        int streakProgress = progressDoc['streak'] ?? 0;

        // Emit ProfileLoaded with both user and progress data
        emit(ProfileLoaded(
          name: name,
          dateJoined: dateJoined,
          lessonsProgress: lessonsProgress,
          categoriesProgress: categoriesProgress,
          minutesProgress: minutesProgress,
          daysProgress: daysProgress,
          streakProgress: streakProgress,
        ));
      } else {
        emit(ProfileError("Progress data not found"));
      }
    } else {
      emit(ProfileError("User not found"));
    }
  } catch (e) {
    emit(ProfileError("Failed to fetch user data: ${e.toString()}"));
  }
}


  String capitalize(String input) {
    if (input.isEmpty) return '';
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }
}
