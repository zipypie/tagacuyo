// translation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'translator_event.dart';
import 'translator_state.dart';

class TranslatorBloc extends Bloc<TranslatorEvent, TranslatorState> {
  bool isCuyononToTagalog = false;

  TranslatorBloc() : super(TranslatorInitial()) {
    on<ToggleTranslationDirection>((event, emit) {
      isCuyononToTagalog = !isCuyononToTagalog;
      emit(TranslatorDirectionToggled(isCuyononToTagalog));
    });

    on<TranslateText>((event, emit) {
      // Check if the input text is empty
      if (event.text.isEmpty) {
        emit(TranslatorTranslated('', characterCount: 0)); // Emit with empty string and count 0
      } else {
        // Implement your translation logic here
        final translatedText = event.text; // Placeholder for actual translation
        final characterCount = translatedText.length; // Get character count
        emit(TranslatorTranslated(translatedText, characterCount: characterCount));
      }
    });
  }
}
