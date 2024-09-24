import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _cuyononController = TextEditingController();
  final TextEditingController _tagalogController = TextEditingController();
  String _cuyononText = '';
  String _tagalogText = '';
  bool _isCuyononToTagalog = true; // Track translation direction

  void _translate() {
    setState(() {
      _tagalogText = 'Translated: $_cuyononText'; // Example translation
      _tagalogController.text = _tagalogText;
    });
  }

  void _toggleTranslationDirection() {
    setState(() {
      _isCuyononToTagalog = !_isCuyononToTagalog;
      // Clear text fields when switching direction
      _cuyononController.clear();
      _tagalogController.clear();
    });
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, bool isReadOnly) {
    return Padding(
      padding: const EdgeInsets.all(25.0), // Space between text fields
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            readOnly: isReadOnly,
            maxLines: 6, // Allow maximum of 6 lines
            minLines: 6, // Start with at least 1 line
            onChanged: isReadOnly
                ? null
                : (text) {
                    setState(() {
                      _cuyononText = text; // Update the Cuyonon text
                    });
                  },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.lightBlue[100],
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                borderSide: BorderSide.none, // Removes the border line
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                borderSide:
                    BorderSide.none, // Removes the border line when enabled
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                borderSide:
                    BorderSide.none, // Removes the border line when focused
              ),
            ),
          ),
          // Container for the text count and copy button
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: 0, horizontal: 20), // Padding inside the container
            decoration: BoxDecoration(
              color: Colors.lightBlue[100], // Background color
              border: const Border(
                top: BorderSide(width: 1, color: Colors.black), // Top border
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ), // Rounded corners
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${controller.text.length}/500',
                    style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    // Handle copy action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _toggleTranslationDirection,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _isCuyononToTagalog
                    ? 'assets/icons/translator_ct_active.png' // Cuyonon to Tagalog image
                    : 'assets/icons/translator_active.png', // Tagalog to Cuyonon image
                height: 40, // Adjust height as needed
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Image not found', // Fallback text in case of an error
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  );
                },
              ),
              const SizedBox(width: 8), // Spacing between image and text
              Text(
                _isCuyononToTagalog
                    ? 'Cuyonon to Tagalog' // Title for Cuyonon to Tagalog
                    : 'Tagalog to Cuyonon', // Title for Tagalog to Cuyonon
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        centerTitle: true, // Optional: centers the title in the app bar
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_cuyononController, 'Cuyonon', !_isCuyononToTagalog),
              _buildTextField(_tagalogController, 'Tagalog', _isCuyononToTagalog),
              MyButton(
                onTab: _translate, // Use the _translate function
                text: 'Translate',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
