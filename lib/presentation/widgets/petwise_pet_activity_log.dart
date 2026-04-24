import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PetwisePetActivityLog extends StatelessWidget {
  const PetwisePetActivityLog({super.key});

  @override
  Widget build(BuildContext context) {
    return
      IntrinsicHeight(
        child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                          top: 0,
                          bottom: 0,
                          left: 33.5,
                          child: Container(
                            width: 3,
                            color: Colors.grey.shade500,
                          )
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.arrow_drop_up_outlined, color: Colors.white, size: 45),
                        ),
                      )
                    ]
                ),
              ),

              const SizedBox(width: 20),
              Expanded(
                child:
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("2H AGO",
                          style: GoogleFonts.plusJakartaSans(color: Colors.orange, fontSize: 17, fontWeight: FontWeight.bold)),
                      Text("45 Min Walk",
                          style: GoogleFonts.plusJakartaSans(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      Text("Active Session around grand central park 🐈",
                          style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 15, letterSpacing: -0.5)),

                    ],
                  ),
                ),
              ),
            ]
        ),
      );
  }
}
