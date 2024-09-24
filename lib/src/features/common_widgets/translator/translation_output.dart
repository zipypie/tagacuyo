import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taga_cuyo/src/features/common_widgets/translator/translation_bloc.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart'; // Assuming you are using BLoC


class TranslationOutput extends StatefulWidget {
  const TranslationOutput({super.key});

  @override
  State<TranslationOutput> createState() => _TranslationOutputState();
}

class _TranslationOutputState extends State<TranslationOutput> {
  final TextEditingController _controller = TextEditingController();
  final int _maxLength = 100; // Define your max length

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
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
        BlocBuilder<TranslationBloc, int>(
          builder: (context, charCount) {
            return Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.titleColor, width: 2), // Top border
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
    );
  }
}
