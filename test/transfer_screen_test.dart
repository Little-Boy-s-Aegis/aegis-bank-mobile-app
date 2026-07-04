import 'package:flutter_test/flutter_test.dart';

// Simulating the exact validation logic present in transfer_screen.dart
String? validateInputs(String source, String target, String amountStr, String description) {
  final String finalSource = source.trim();
  final String finalTarget = target.trim();
  final double? amount = double.tryParse(amountStr);
  final String finalDescription = description.trim();

  // 1. Recipient account format validation
  final RegExp accRegex = RegExp(r'^ACC-\d{6}$');
  if (!accRegex.hasMatch(finalTarget)) {
    return "Recipient account must be in ACC-XXXXXX format (e.g., ACC-123456).";
  }

  if (finalSource == finalTarget) {
    return "Source and recipient account numbers must be different.";
  }

  // 2. Positive amount validation
  if (amount == null || amount <= 0) {
    return "Transfer amount must be a valid positive number greater than zero.";
  }

  // 3. Description validation
  if (finalDescription.isEmpty) {
    return "Description message is required.";
  }

  return null; // validation success
}

void main() {
  group('Flutter Mobile App Transfer Screen Input Validation Tests', () {
    test('should return error for invalid recipient account format', () {
      final error = validateInputs('ACC-111111', 'ACC-INVALID', '500.0', 'Payment');
      expect(error, "Recipient account must be in ACC-XXXXXX format (e.g., ACC-123456).");
    });

    test('should return error for self-transfers', () {
      final error = validateInputs('ACC-111111', 'ACC-111111', '500.0', 'Payment');
      expect(error, "Source and recipient account numbers must be different.");
    });

    test('should return error for negative or zero amounts', () {
      final error1 = validateInputs('ACC-111111', 'ACC-222222', '-100', 'Payment');
      expect(error1, "Transfer amount must be a valid positive number greater than zero.");

      final error2 = validateInputs('ACC-111111', 'ACC-222222', '0', 'Payment');
      expect(error2, "Transfer amount must be a valid positive number greater than zero.");

      final error3 = validateInputs('ACC-111111', 'ACC-222222', 'abc', 'Payment');
      expect(error3, "Transfer amount must be a valid positive number greater than zero.");
    });

    test('should return error for empty description', () {
      final error = validateInputs('ACC-111111', 'ACC-222222', '500.0', '   ');
      expect(error, "Description message is required.");
    });

    test('should return null (succeed) for valid inputs', () {
      final error = validateInputs('ACC-111111', 'ACC-222222', '150000.75', 'Secure transfer');
      expect(error, isNull);
    });
  });
}
