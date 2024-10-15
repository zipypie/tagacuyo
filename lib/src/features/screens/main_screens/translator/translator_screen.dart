import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'translation_bloc.dart';
import 'translator_event.dart';
import 'translator_state.dart';

class TranslatorScreen extends StatelessWidget {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  TranslatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TranslatorBloc(),
      child: BlocBuilder<TranslatorBloc, TranslatorState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<TranslatorBloc>(context);

          // Update output text controller based on the state
          if (state is TranslatorTranslated) {
            _outputController.text = state.translatedText;
          }

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        cubit.add(ToggleTranslationDirection());
                      },
                      child: Image.asset(
                        cubit.isCuyononToTagalog
                            ? 'assets/icons/translator_ct_active.png'
                            : 'assets/icons/translator_active.png',
                        height: 40,
                      ),
                    ),
                    _buildInputContainer(cubit, state), // Pass state as a parameter
                    _buildOutputContainer(cubit),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

Widget _buildInputContainer(TranslatorBloc cubit, TranslatorState state) {
  return Container(
    padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cubit.isCuyononToTagalog ? 'Cuyonon' : 'Tagalog',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: _inputController,
          maxLines: 7,
          onChanged: (text) {
            // Trim whitespace to avoid counting it as a character
            String trimmedText = text.trim();
            if (trimmedText.isEmpty) {
              _outputController.clear(); // Clear the output text when input is empty
              cubit.add(TranslateText(trimmedText)); // Emit event for empty input
            } else {
              cubit.add(TranslateText(trimmedText)); // Emit event for non-empty input
            }
            // Dispatch event to update character count (this line can be omitted)
            // You may remove this if you don't need to manually update
            // cubit.add(UpdateCharacterCount(trimmedText.length)); 
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.lightBlue[100],
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            border: const Border(
              top: BorderSide(width: 1, color: Colors.black),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Update character count display based on current state
                Text(
                  state is TranslatorTranslated
                      ? '${state.characterCount} characters'
                      : '0 characters', // Default to 0 if state is not TranslatorTranslated
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _inputController.text));
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildOutputContainer(TranslatorBloc cubit) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cubit.isCuyononToTagalog ? 'Tagalog' : 'Cuyonon',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _outputController, // Use _outputController for output
            maxLines: 7,
            readOnly:
                true, // Make it read-only if it's just for displaying translation
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.lightBlue[100],
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.lightBlue[100], // Color inside BoxDecoration
              borderRadius: const BorderRadius.only(
                bottomLeft:
                    Radius.circular(10), // Correct radius for the bottom
                bottomRight:
                    Radius.circular(10), // Correct radius for the bottom
              ),
              border: const Border(
                top: BorderSide(
                    width: 1, color: Colors.black), // Only top border
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${_outputController.text.length} characters'), // Count characters in output
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Implement copy to clipboard functionality
                      Clipboard.setData(
                        ClipboardData(text: _outputController.text),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
