import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taga_cuyo/src/features/common_widgets/translator/character_input.dart';
import 'package:taga_cuyo/src/features/common_widgets/translator/translation_bloc.dart';
// Import the custom input widget

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TranslationBloc(500),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const CharacterCountInput(), // Use the custom widget
              Container(), 
              // An empty Container, possibly needs to be filled
            ],
          ),
        ),
      ),
    );
  }
}
