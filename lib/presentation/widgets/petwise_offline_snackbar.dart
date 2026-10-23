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
    IconData icon = Icons.error_outline_rounded,
    Color? iconColor,
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
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: iconColor != null
                ? iconColor.withValues(alpha: 0.35)
                : Colors.red.shade200,
            width: 1.2,
          ),
        ),
        duration: duration,
        content: _OfflineSnackbarContent(
          title: title,
          message: message,
          icon: icon,
          iconColor: iconColor,
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
    IconData icon = Icons.error_outline_rounded,
    Color? iconColor,
    FutureOr<void> Function()? onRetry,
    VoidCallback? onCancel,
    Duration duration = const Duration(seconds: 10),
  }) {
    show(
      context,
      title: error.title,
      message: error.message,
      icon: icon,
      iconColor: iconColor,
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
  final IconData icon;
  final Color? iconColor;
  final FutureOr<void> Function()? onRetry;
  final VoidCallback? onCancel;

  const _OfflineSnackbarContent({
    required this.title,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.iconColor,
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
    final effectiveIconColor = widget.iconColor ?? Colors.red.shade600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Error / Status Icon Badge in red tint
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: effectiveIconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: effectiveIconColor, size: 19),
        ),
        const SizedBox(width: 10),

        // Text & Instructions matching PetWise page typography
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF1A2D40), // PetWise primary navy
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.message,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B), // Slate-500 subtitle
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),

        // Actions: Cancel & Retry
        if (widget.onRetry != null) ...[
          const SizedBox(width: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
          // Active Retry Pill Action (remains orange)
          InkWell(
            onTap: _isRetrying ? null : _handleRetry,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
