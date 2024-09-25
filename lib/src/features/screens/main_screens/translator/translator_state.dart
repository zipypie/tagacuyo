// translator_state.dart
abstract class TranslatorState {}

class TranslatorInitial extends TranslatorState {}

class TranslatorDirectionToggled extends TranslatorState {
  final bool isCuyononToTagalog;

  TranslatorDirectionToggled(this.isCuyononToTagalog);
}

class TranslatorTranslated extends TranslatorState {
  final String translatedText;

  TranslatorTranslated(this.translatedText);
}
