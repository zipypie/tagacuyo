import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String dateJoined;
  final int lessonsProgress;
  final int categoriesProgress;
  final int minutesProgress;
  final int daysProgress;
  final int streakProgress;

  ProfileLoaded({
    required this.name,
    required this.dateJoined,
    required this.lessonsProgress,
    required this.categoriesProgress,
    required this.minutesProgress,
    required this.daysProgress,
    required this.streakProgress,
  });

  @override
  List<Object> get props => [
        name,
        dateJoined,
        lessonsProgress,
        categoriesProgress,
        minutesProgress,
        daysProgress,
        streakProgress
      ];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object> get props => [message];
}
