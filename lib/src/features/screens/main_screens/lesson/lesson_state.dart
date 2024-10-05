abstract class LessonState {}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class LessonLoaded extends LessonState {
  final List<Map<String, dynamic>> lessons;
  final int maxLength;
  LessonLoaded(this.lessons, this.maxLength);
}

class LessonError extends LessonState {
  final String message;

  LessonError(this.message);
}
