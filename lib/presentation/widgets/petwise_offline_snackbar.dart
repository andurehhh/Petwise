import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/error_mapper.dart';

/// A reusable, non-blocking floating snackbar designed for offline and
/// network drop feedback throughout the PetWise app.
///
/// Features:
/// - Floating toast with PetWise dark-slate styling and rounded corners.
/// - Clear connectivity instructions without exposing technical endpoints.
/// - Active `onRetry` callback that displays an inline spinner while executing,
///   prevents multi-tap spam, and automatically dismisses on success.
///
/// Usage:
/// ```dart
/// PetwiseOfflineSnackbar.show(
///   context,
///   onRetry: () async {
///     await context.read<PetProvider>().loadUserPets(userId);
///   },
/// );
/// ```
class PetwiseOfflineSnackbar {
  /// Displays a floating offline snackbar with active Retry and Cancel actions.
  static void show(
    BuildContext context, {
    String title = "You're offline",
    String message = 'Check your connection, then tap retry.',
    FutureOr<void> Function()? onRetry,
    VoidCallback? onCancel,
    Duration duration = const Duration(seconds: 10),
  }) {
    // Dismiss any existing snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 6,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: const Color(0xFFF7A433).withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        duration: duration,
        content: _OfflineSnackbarContent(
          title: title,
          message: message,
          onRetry: onRetry,
          onCancel: onCancel,
        ),
      ),
    );
  }

  /// Convenience method that takes an [AppError] directly.
  static void showError(
    BuildContext context, {
    required AppError error,
    FutureOr<void> Function()? onRetry,
    VoidCallback? onCancel,
    Duration duration = const Duration(seconds: 10),
  }) {
    show(
      context,
      title: error.title,
      message: error.message,
      onRetry: onRetry,
      onCancel: onCancel,
      duration: duration,
    );
  }

  /// Immediately hides any active snackbar.
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

class _OfflineSnackbarContent extends StatefulWidget {
  final String title;
  final String message;
  final FutureOr<void> Function()? onRetry;
  final VoidCallback? onCancel;

  const _OfflineSnackbarContent({
    required this.title,
    required this.message,
    this.onRetry,
    this.onCancel,
  });

  @override
  State<_OfflineSnackbarContent> createState() =>
      _OfflineSnackbarContentState();
}

class _OfflineSnackbarContentState extends State<_OfflineSnackbarContent> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null || _isRetrying) return;

    setState(() => _isRetrying = true);

    try {
      await widget.onRetry!();
      if (mounted) {
        // Successful retry: auto-dismiss the snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (_) {
      // Failed retry: re-enable button so user can attempt again
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Offline Icon Badge in soft amber tint
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF7A433).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFFF7A433),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Text & Instructions matching PetWise page typography
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF1A2D40), // PetWise primary navy
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B), // Slate-500 subtitle
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),

        // Actions: Cancel & Retry
        if (widget.onRetry != null) ...[
          const SizedBox(width: 8),
          // Cancel Action
          InkWell(
            onTap: _isRetrying
                ? null
                : () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    widget.onCancel?.call();
                  },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Active Retry Pill Action
          InkWell(
            onTap: _isRetrying ? null : _handleRetry,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF7A433), // PetWise branded amber
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF7A433).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isRetrying
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Retry',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

