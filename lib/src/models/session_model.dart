import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 0)
class SessionModel {
  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime? endTime; // Nullable endTime

  SessionModel({
    required this.sessionId,
    required this.startTime,
    this.endTime, // Allow endTime to be optional
  });
}
