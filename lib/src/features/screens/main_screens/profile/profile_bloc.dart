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
      final userDoc = await userService.getUserById(event.uid);

      if (userDoc != null && userDoc.exists) {
        String firstName = userDoc['firstname'] ?? '';
        String lastName = userDoc['lastname'] ?? '';
        String name = '${capitalize(firstName)} ${capitalize(lastName)}';

        // Fetch date joined from Firestore
        Timestamp joinedTimestamp = userDoc['date_joined'] ?? Timestamp.now();
        String dateJoined = joinedTimestamp.toDate().toLocal().toString().split(' ')[0];

        emit(ProfileLoaded(name: name, dateJoined: dateJoined));
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
