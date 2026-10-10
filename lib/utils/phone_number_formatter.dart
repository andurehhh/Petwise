import 'package:flutter/services.dart';

/// Available hyphenation patterns for mobile numbers.
enum MobileNumberFormat {
  /// 09xx-xxxx-xxx (11 digits: 4 digits prefix, 4 digits, 3 digits, e.g. 0917-1234-567)
  fourFourThree,

  /// 09x-xxxx-xxx / 09x-xxxx-xxxx (3 digits prefix, 4 digits, 3/4 digits, e.g. 091-7123-4567)
  threeFourFour,

  /// 09xx-xxx-xxxx (11 digits: 4 digits prefix, 3 digits, 4 digits, e.g. 0917-123-4567)
  fourThreeFour,
}

/// A [TextInputFormatter] that formats mobile numbers dynamically as the user types
/// into standard hyphenated blocks (defaults to 09xx-xxxx-xxx).
class MobileNumberInputFormatter extends TextInputFormatter {
  final MobileNumberFormat formatType;

  const MobileNumberInputFormatter({
    this.formatType = MobileNumberFormat.fourFourThree,
  });

  /// Formats an unformatted phone string into the specified hyphenated format.
  static String format(
    String rawNumber, {
    MobileNumberFormat formatType = MobileNumberFormat.fourFourThree,
  }) {
    if (rawNumber.isEmpty) return '';

    String digits = rawNumber.replaceAll(RegExp(r'\D'), '');

    // Handle pasted +63 or 639
    if (digits.startsWith('639')) {
      digits = '09${digits.substring(3)}';
    }

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    return _applyFormat(digits, formatType);
  }

  static String _applyFormat(String digits, MobileNumberFormat formatType) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();

    int firstCut;
    int secondCut;

    switch (formatType) {
      case MobileNumberFormat.fourFourThree:
        firstCut = 4; // 09xx
        secondCut = 8; // 09xx-xxxx
        break;
      case MobileNumberFormat.threeFourFour:
        firstCut = 3; // 09x
        secondCut = 7; // 09x-xxxx
        break;
      case MobileNumberFormat.fourThreeFour:
        firstCut = 4; // 09xx
        secondCut = 7; // 09xx-xxx
        break;
    }

    for (int i = 0; i < digits.length; i++) {
      if (i == firstCut || i == secondCut) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 1. Keep only digits
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // 2. Handle pasted +639 or 639
    if (digits.startsWith('639')) {
      digits = '09${digits.substring(3)}';
    }

    // 3. Limit to maximum 11 digits
    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    // 4. Build formatted text
    final formattedText = _applyFormat(digits, formatType);

    // 5. Compute cursor position smoothly without jumping
    int digitsBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.end && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    int newCursorPos = 0;
    int digitsCounted = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (digitsCounted >= digitsBeforeCursor) {
        break;
      }
      if (RegExp(r'\d').hasMatch(formattedText[i])) {
        digitsCounted++;
      }
      newCursorPos = i + 1;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}
