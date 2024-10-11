//profile_state.dart


import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String dateJoined;
  final String profileImageUrl; // Add this line
  final int lessonsProgress;
  final int categoriesProgress;
  final int minutesProgress;
  final int daysProgress;
  final int streakProgress;
  final int longestStreakProgress;

  ProfileLoaded({
    required this.name,
    required this.dateJoined,
    required this.profileImageUrl, // Add this line
    required this.lessonsProgress,
    required this.categoriesProgress,
    required this.minutesProgress,
    required this.daysProgress,
    required this.streakProgress,
    required this.longestStreakProgress,
  });

  @override
  List<Object> get props => [
        name,
        dateJoined,
        lessonsProgress,
        categoriesProgress,
        minutesProgress,
        daysProgress,
        streakProgress,
        longestStreakProgress
      ];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object> get props => [message];
}
