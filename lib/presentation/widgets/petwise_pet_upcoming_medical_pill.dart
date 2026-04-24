import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PetwiseUpcomingMedicalPill extends StatelessWidget {
  const PetwiseUpcomingMedicalPill({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Container(
        margin: EdgeInsets.all(5),
        child:
          GestureDetector(
            onTap: (){},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
              decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: Color(0xFFB3B0B0),
                    width: 2,
                  )
          
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.medical_services_outlined, color: Color(0xFFB3B0B0),),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Medical checkup",
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black45, fontWeight: FontWeight.w600)),
                      Text("Perpetual Help Systems",
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600)),
          
                    ],
                  ),
                  Spacer(),
                  Text("June 10, 2026",
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600),)
                ],
              ),
            ),
          ),
      )
    ;
  }
}
