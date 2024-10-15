// translator_event.dart
abstract class TranslatorEvent {}

class ToggleTranslationDirection extends TranslatorEvent {}

class TranslateText extends TranslatorEvent {
  final String text;

  TranslateText(this.text);
}

class UpdateCharacterCount extends TranslatorEvent {
  final int count;
  UpdateCharacterCount(this.count);
}