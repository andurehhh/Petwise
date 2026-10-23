import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/error_mapper.dart';

/// A reusable, modal error bottom sheet designed for critical failure states,
/// network disconnects, and operation recovery in the PetWise app.
///
/// Features:
/// - Consistent PetWise styling with rounded top corners and soft elevation.
/// - Human-friendly explanations + a structured troubleshooting checklist.
/// - Optional collapsible technical details view for debugging (no raw leaks to users).
/// - Active `onRetry` callback that manages its own loading spinner, prevents
///   multi-tap spam, auto-dismisses on success, and alerts the user if the retry fails.
///
/// Usage:
/// ```dart
/// await PetwiseErrorBottomSheet.show(
///   context: context,
///   title: 'Unable to Load Pets',
///   message: 'We could not reach the server to fetch your pet records.',
///   technicalDetails: e.toString(),
///   onRetry: () async {
///     await context.read<PetProvider>().loadUserPets(userId);
///   },
/// );
/// ```
class PetwiseErrorBottomSheet {
  /// Shows the error bottom sheet modal with custom parameters.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    List<String>? instructions,
    String? technicalDetails,
    Future<void> Function()? onRetry,
    bool isOffline = false,
    String retryButtonLabel = 'Try Again',
    String dismissButtonLabel = 'Dismiss',
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ErrorBottomSheetContent(
        title: title,
        message: message,
        instructions: instructions,
        technicalDetails: technicalDetails,
        onRetry: onRetry,
        isOffline: isOffline,
        retryButtonLabel: retryButtonLabel,
        dismissButtonLabel: dismissButtonLabel,
      ),
    );
  }

  /// Convenience method that consumes an [AppError] directly.
  static Future<T?> showError<T>({
    required BuildContext context,
    required AppError error,
    Future<void> Function()? onRetry,
    String retryButtonLabel = 'Try Again',
    String dismissButtonLabel = 'Dismiss',
  }) {
    return show<T>(
      context: context,
      title: error.title,
      message: error.message,
      instructions: error.instructions,
      technicalDetails: error.technicalDetails,
      isOffline: error.isOffline,
      onRetry: onRetry,
      retryButtonLabel: retryButtonLabel,
      dismissButtonLabel: dismissButtonLabel,
    );
  }

  /// Shorthand helper specifically tailored for offline / network loss scenarios.
  static Future<T?> showOffline<T>({
    required BuildContext context,
    String title = 'No Internet Connection',
    String message =
        'We could not connect to PetWise servers. Please check your network and try again.',
    Future<void> Function()? onRetry,
  }) {
    return show<T>(
      context: context,
      title: title,
      message: message,
      isOffline: true,
      onRetry: onRetry,
      instructions: const [
        'Check if your Wi-Fi or mobile data is turned on',
        'Verify that Airplane Mode is turned off',
        'Tap "Try Again" below once your connection is back',
      ],
    );
  }
}

class _ErrorBottomSheetContent extends StatefulWidget {
  final String? title;
  final String? message;
  final List<String>? instructions;
  final String? technicalDetails;
  final Future<void> Function()? onRetry;
  final bool isOffline;
  final String retryButtonLabel;
  final String dismissButtonLabel;

  const _ErrorBottomSheetContent({
    this.title,
    this.message,
    this.instructions,
    this.technicalDetails,
    this.onRetry,
    this.isOffline = false,
    this.retryButtonLabel = 'Try Again',
    this.dismissButtonLabel = 'Dismiss',
  });

  @override
  State<_ErrorBottomSheetContent> createState() =>
      _ErrorBottomSheetContentState();
}

class _ErrorBottomSheetContentState extends State<_ErrorBottomSheetContent> {
  bool _isRetrying = false;
  String? _retryErrorMessage;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null || _isRetrying) return;

    setState(() {
      _isRetrying = true;
      _retryErrorMessage = null;
    });

    try {
      await widget.onRetry!();
      if (mounted) {
        // Success: auto-dismiss the bottom sheet
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final error = ErrorMapper.from(e);
        setState(() {
          _isRetrying = false;
          _retryErrorMessage =
              'Retry attempt failed: ${error.message}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = widget.title ??
        (widget.isOffline
            ? 'No Internet Connection'
            : 'Something Went Wrong');

    final effectiveMessage = widget.message ??
        (widget.isOffline
            ? 'We could not connect to the server. Please check your network settings.'
            : 'An unexpected issue occurred while processing your request.');

    final effectiveInstructions = widget.instructions ??
        (widget.isOffline
            ? const [
                'Ensure Wi-Fi or cellular data is enabled',
                'Disable Airplane Mode if it is active',
                'Tap "Try Again" below to reconnect',
              ]
            : const [
                'Verify your internet connection is stable',
                'Tap "Try Again" to re-fetch the data',
                'If the problem continues, please try again in a few moments',
              ]);

    final accentColor = widget.isOffline
        ? const Color(0xFFF7A433)
        : Colors.red.shade600;

    final badgeBgColor = widget.isOffline
        ? const Color(0xFFF7A433).withValues(alpha: 0.12)
        : Colors.red.shade50;

    final icon = widget.isOffline
        ? Icons.wifi_off_rounded
        : Icons.error_outline_rounded;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Icon Badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  effectiveTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A2D40),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Explanation Message
                Text(
                  effectiveMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Clear Troubleshooting Instructions Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: Color(0xFFF7A433),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'What you can do:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A2D40),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...effectiveInstructions.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE2E8F0),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF475569),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Optional Collapsible Technical Details (for debugging)
                if (widget.technicalDetails != null &&
                    widget.technicalDetails!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      title: Text(
                        'Technical details',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SelectableText(
                            widget.technicalDetails!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Retry Error Feedback Banner (if a retry attempt failed)
                if (_retryErrorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _retryErrorMessage!,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.red.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Secondary Dismiss Button
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: _isRetrying
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          widget.dismissButtonLabel,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    // Primary Active Retry Button
                    if (widget.onRetry != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _isRetrying ? null : _handleRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF7A433),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFF7A433)
                                .withValues(alpha: 0.6),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isRetrying
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Retrying...',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.refresh_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.retryButtonLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

