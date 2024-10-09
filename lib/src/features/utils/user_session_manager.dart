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

    // Notify listeners about the session start
    onSessionStarted?.call(_sessionStartTime!);

    // Create a new session in Firestore and store its ID
    if (userService.currentUserId != null) {
      final activeSessionId = await userService.getActiveSessionId(userService.currentUserId!);
      if (activeSessionId != null) {
        await userService.endUserSession(userService.currentUserId!, activeSessionId, DateTime.now());
      }

      // Create new session
      _currentSessionId = await userService.createUserSession(userService.currentUserId!, _sessionStartTime!);
    } else {
    }
  }

  Future<void> endSession() async {
    if (_sessionStartTime != null) {
      _sessionEndTime = DateTime.now(); // Capture end time
      final sessionDuration = _sessionEndTime!.difference(_sessionStartTime!).inMinutes;
      // Notify listeners about the session end
      onSessionEnded?.call(_sessionEndTime!);

      // Increment the user's session minutes in the database
      if (userService.currentUserId != null) {
        try {
          await userService.incrementSessionMinutes(userService.currentUserId!, sessionDuration);

          // Get the active session ID before ending the session
          final activeSessionId = await userService.getActiveSessionId(userService.currentUserId!);

          // End the user session in Firestore and include end time
          if (activeSessionId != null) {
            await userService.endUserSession(userService.currentUserId!, activeSessionId, _sessionEndTime!);
          } else {
          }
        } catch (error) {
          Logger.log('Error ending session: $error'); // Log any errors
        }
      } else {
        Logger.log('No user is currently logged in. Session not recorded.');
      }

      // Reset session variables
      _sessionStartTime = null;
      _currentSessionId = null;
    } else {
      Logger.log('No session to end.'); // Additional log for no active session
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Resume session if there was a previous session
      if (_currentSessionId != null) {
        Logger.log('Resuming session with ID: $_currentSessionId');
        startSession(); // Optionally restart a new session
      } else {
        startSession(); // Start a new session when the app is resumed
      }
    } else if (state == AppLifecycleState.paused) {
      Logger.log('App paused. Ending session...');
      endSession().then((_) {
        Logger.log('Session ended successfully on pause.');
      });
    } else if (state == AppLifecycleState.detached) {
      Logger.log('App detached. Ending session...');
      endSession().then((_) {
        Logger.log('Session ended successfully on detach.');
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
