String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text; // Return the original string if it's empty
  }
  return text[0].toUpperCase() + text.substring(1);
}
