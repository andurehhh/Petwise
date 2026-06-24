import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A themed success / failure modal used throughout the app.
///
/// Usage:
/// ```dart
/// await PetwiseConfirmationDialog.show(
///   context: context,
///   success: true,
///   title: 'Activity Added',
///   message: 'Your activity has been scheduled.',
/// );
/// ```
class PetwiseConfirmationDialog {
  static Future<void> show({
    required BuildContext context,
    required bool success,
    required String title,
    required String message,
    String buttonLabel = 'OK',
    VoidCallback? onDismissed,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ConfirmationDialogContent(
        success: success,
        title: title,
        message: message,
        buttonLabel: buttonLabel,
      ),
    );
    onDismissed?.call();
  }
}

class _ConfirmationDialogContent extends StatelessWidget {
  final bool success;
  final String title;
  final String message;
  final String buttonLabel;

  const _ConfirmationDialogContent({
    required this.success,
    required this.title,
    required this.message,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = success ? const Color(0xFF4CAF50) : Colors.redAccent;
    final icon = success ? Icons.check_circle_rounded : Icons.error_rounded;

    return Dialog(
      backgroundColor: const Color(0xffFFF9EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A2D40),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xffA5927D),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: success
                      ? const Color(0xFFF4AD44)
                      : Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
