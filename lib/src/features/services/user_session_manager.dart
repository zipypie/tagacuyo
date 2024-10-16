import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

class UserSessionManager with WidgetsBindingObserver {
  final UserService userService;
  DateTime? _sessionStartTime;
  DateTime? _sessionEndTime;
  String? _currentSessionId;

  // Callbacks for session events
  Function(DateTime)? onSessionStarted;
  Function(DateTime)? onSessionEnded;

  UserSessionManager(this.userService) {
    WidgetsBinding.instance.addObserver(this);
    startSession(); // Start session immediately on initialization
  }

  void startSession() async {
  _sessionStartTime = DateTime.now();

  // Check if _sessionStartTime is not null before calling onSessionStarted
  if (_sessionStartTime != null) {
    onSessionStarted?.call(_sessionStartTime!);
  }

  // Create a new session in Firestore if user ID is available
  if (userService.currentUserId != null) {
    final activeSessionId = await userService.getActiveSessionId(userService.currentUserId!);
    if (activeSessionId != null) {
      await userService.endUserSession(userService.currentUserId!, activeSessionId, DateTime.now());
    }

    // Create new session
    _currentSessionId = await userService.createUserSession(userService.currentUserId!, _sessionStartTime!);
  } else {
    Logger.log('User ID is null. Cannot start session.');
  }
}

 Future<void> endSession() async {
  if (_sessionStartTime != null) {
    _sessionEndTime = DateTime.now(); // Capture end time
    final sessionDuration = _sessionEndTime!.difference(_sessionStartTime!).inMinutes;

    onSessionEnded?.call(_sessionEndTime!);

    if (userService.currentUserId != null) {
      try {
        await userService.incrementSessionMinutes(userService.currentUserId!, sessionDuration);

        final activeSessionId = await userService.getActiveSessionId(userService.currentUserId!);
        if (activeSessionId != null) {
          await userService.endUserSession(userService.currentUserId!, activeSessionId, _sessionEndTime!);
        } else {
          Logger.log('No active session to end.');
        }
      } catch (error) {
        Logger.log('Error ending session: $error');
      }
    } else {
      Logger.log('No user is currently logged in. Session not recorded.');
    }

    // Reset session variables
    _sessionStartTime = null;
    _currentSessionId = null;
  } else {
    Logger.log('No session to end.');
  }
}

 @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    Logger.log('App resumed. Current session ID: $_currentSessionId');
    if (_currentSessionId == null) {
      startSession(); // Start a new session if none exists
    } else {
      Logger.log('Resuming existing session with ID: $_currentSessionId');
    }
  } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
    Logger.log('App paused/detached. Ending session...');
    endSession().then((_) {
      Logger.log('Session ended successfully on pause/detach.');
    });
  }
}


  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    endSession().then((_) {
      Logger.log('Session ended successfully on dispose.');
    });
  }
}
