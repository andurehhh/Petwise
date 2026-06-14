import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PetwiseUserTextfield extends StatefulWidget {
  final String textLabel;
  final String? textHint;
  final TextEditingController? controller;
  final bool isEditable;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const PetwiseUserTextfield({
    super.key,
    required this.textLabel,
    this.textHint,
    this.controller,
    this.isEditable = false,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
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
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.textLabel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(width: 1.5, color: const Color(0xFFDCDCDC)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      enabled: widget.isEditable,
                      obscureText: _hidden,
                      textInputAction:
                          widget.textInputAction ?? TextInputAction.next,
                      onSubmitted:
                          widget.onSubmitted != null
                              ? (_) => widget.onSubmitted!()
                              : null,
                      style: GoogleFonts.plusJakartaSans(fontSize: 15),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.textHint,
                      ),
                    ),
                  ),
                  if (widget.obscureText)
                    GestureDetector(
                      onTap: () => setState(() => _hidden = !_hidden),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          _hidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
