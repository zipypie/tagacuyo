import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UserService _userService = UserService();
  final User? _user = FirebaseAuth.instance.currentUser;

  AccountBloc() : super(AccountInitial());

  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is FetchUserData) {
      yield AccountLoading();
      try {
        DocumentSnapshot? userDoc = await _userService.getUserById(_user!.uid);
        if (userDoc != null) {
          yield AccountLoaded(userDoc['email'] ?? _user.email!);
        } else {
          yield const AccountError('User not found');
        }
      } catch (e) {
        yield AccountError(e.toString());
      }
    } else if (event is UpdateUserData) {
      yield AccountLoading();
      try {
        List<DocumentSnapshot> existingUsers = await _userService.searchUsersByEmail(event.email);
        if (existingUsers.isNotEmpty && existingUsers[0].id != _user!.uid) {
          yield const AccountError('Email is already in use by another account.');
          return;
        }

        // Use reauthenticateWithCredential for re-authentication
        AuthCredential credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: event.password,
        );

        await _user.reauthenticateWithCredential(credential);
        
        await _userService.updateUserEmail(_user.uid, event.email);
        
        yield AccountLoaded(event.email);
      } catch (e) {
        yield AccountError(e.toString());
      }
    }
  }
}
