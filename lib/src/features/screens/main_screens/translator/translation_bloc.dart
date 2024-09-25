// translation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'translator_event.dart';
import 'translator_state.dart';

class TranslatorBloc extends Bloc<TranslatorEvent, TranslatorState> {
  bool isCuyononToTagalog = false;

  TranslatorBloc() : super(TranslatorInitial()) {
    // Add event handlers in the constructor
    on<ToggleTranslationDirection>((event, emit) {
      isCuyononToTagalog = !isCuyononToTagalog;
      emit(TranslatorDirectionToggled(isCuyononToTagalog));
    });

    on<TranslateText>((event, emit) {
      // Implement your translation logic here
      final translatedText = event.text; // Placeholder for actual translation
      emit(TranslatorTranslated(translatedText));
    });
  }

  // You can also implement the translation logic in a separate function if needed.
}
