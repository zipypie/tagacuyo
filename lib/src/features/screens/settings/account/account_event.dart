import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class FetchUserData extends AccountEvent {}

class UpdateUserData extends AccountEvent {
  final String email;
  final String password;
  final String newPassword; // Added for updating password

  const UpdateUserData(this.email, this.password, this.newPassword);

  @override
  List<Object> get props => [email, password, newPassword];
}
