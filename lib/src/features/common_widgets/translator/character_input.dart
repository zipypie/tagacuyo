import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'translation_bloc.dart'; // Import the BLoC

class CharacterCountInput extends StatefulWidget {
  const CharacterCountInput({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CharacterCountInputState createState() => _CharacterCountInputState();
}

class _CharacterCountInputState extends State<CharacterCountInput> {
  final TextEditingController _controller = TextEditingController();
  final int _maxLength = 500;

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (text) {
                // Check if the text exceeds the max length
                if (text.length > _maxLength) {
                  // If it exceeds, truncate the text
                  _controller.text = text.substring(0, _maxLength);
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _maxLength),
                  );
                }
                // Update the character count in BLoC
                context.read<TranslationBloc>().updateCharacterCount(_controller.text);
              },
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
          BlocBuilder<TranslationBloc, int>(
            builder: (context, charCount) {
              return Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.titleColor, width: 2), // Top border
                    bottom: BorderSide.none,
                    left: BorderSide.none,
                    right: BorderSide.none,
                  ),
                ),
                padding: const EdgeInsets.only(top: 8.0), // Add padding to the top
                alignment: Alignment.centerLeft, // Align text to the left
                child: Text(
                  '$charCount/$_maxLength',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
