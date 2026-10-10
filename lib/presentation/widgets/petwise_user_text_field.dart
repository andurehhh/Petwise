import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PetwiseUserTextfield extends StatefulWidget {
  final String textLabel;
  final String? textHint;
  final TextEditingController? controller;
  final bool isEditable;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const PetwiseUserTextfield({
    super.key,
    required this.textLabel,
    this.textHint,
    this.controller,
    this.isEditable = false,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.keyboardType,
    this.validator,
    this.autovalidateMode,
    this.inputFormatters,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  State<PetwiseUserTextfield> createState() => _PetwiseUserTextfieldState();
}

class _PetwiseUserTextfieldState extends State<PetwiseUserTextfield> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800, minWidth: 40),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.textLabel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: const Color(0xFF1A2D40),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: widget.controller,
              enabled: widget.isEditable,
              obscureText: _hidden,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              validator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              onChanged: widget.onChanged,
              textInputAction: widget.textInputAction ?? TextInputAction.next,
              onFieldSubmitted: widget.onSubmitted != null
                  ? (_) => widget.onSubmitted!()
                  : null,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: const Color(0xFF1A2D40),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: widget.textHint,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: widget.isEditable
                      ? const Color(0xFF9E9E9E)
                      : (widget.textHint == 'Not set' ||
                              widget.textHint == 'No Email Registered'
                          ? Colors.grey.shade400
                          : const Color(0xFF1A2D40)),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      const BorderSide(width: 1.5, color: Color(0xFFDCDCDC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      const BorderSide(width: 1.5, color: Color(0xFFDCDCDC)),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      const BorderSide(width: 1.5, color: Color(0xFFDCDCDC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      const BorderSide(width: 1.5, color: Color(0xFFF7A433)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      const BorderSide(width: 1.5, color: Colors.redAccent),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      const BorderSide(width: 1.5, color: Colors.redAccent),
                ),
                errorStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
                suffixIcon: widget.obscureText
                    ? GestureDetector(
                        onTap: () => setState(() => _hidden = !_hidden),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Icon(
                            _hidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFFAAAAAA),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

