import 'dart:math';

class PasswordGenerator {
  static String generate({
    int length = 16,
    bool useLetters = true,
    bool useNumbers = true,
    bool useSpecial = true,
    bool useUppercase = true,
  }) {
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    const String special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (useLetters) chars += lowercase;
    if (useUppercase) chars += uppercase;
    if (useNumbers) chars += numbers;
    if (useSpecial) chars += special;

    if (chars.isEmpty) return '';

    final Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }
}
