import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PetwiseUserTextfield extends StatelessWidget {
  final String textLabel;
  final String textInput;

  const PetwiseUserTextfield({
   super.key,
   required this.textLabel,
   required this.textInput,

});
  @override
  Widget build(BuildContext context) {
    return
      ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 800,
        ),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("User Name",
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 15)
              ),
              Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      width: 1.5,
                      color: Color(0xFFDCDCDC),
                    )
                ),
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: textInput,

                  ),
                ),
              )
            ],
          ),
        ),
      );
  }
}
