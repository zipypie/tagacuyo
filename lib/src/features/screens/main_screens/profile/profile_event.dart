//profile_event.dart

import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUserProfile extends ProfileEvent {
  final String uid;

  FetchUserProfile(this.uid);

  @override
  List<Object> get props => [uid];
}
