import 'package:flutter_bloc/flutter_bloc.dart';

class TranslationBloc extends Cubit<int> {
  final int maxCharacters;

  TranslationBloc(this.maxCharacters) : super(0);

  void updateCharacterCount(String text) {
    emit(text.length > maxCharacters ? maxCharacters : text.length);
  }
}
