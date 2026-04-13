import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/presentation/widgets/petwise_Navbar.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        backgroundColor: Color(0xFFF8F7F6),
        extendBody: true,
       appBar: AppBar(
         leading:
         IconButton(
             onPressed: (){
               Navigator.pop(context);
         },
             icon: Icon(CupertinoIcons.back)),
       ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 72,
                        backgroundColor: Color(0xFFF7A433),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: AssetImage('assets/images/avatar.png'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF7A433),
                            ),
                            child: IconButton(
                              onPressed: (){},
                              icon: Icon(Icons.edit),
                            )
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                    width: 40,
                  ),
                  Text("Lady Gaga"),
                  SizedBox(
                    height: 20,
                    width: 40,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1000
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        // color: Colors.pink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("USER INFORMATION",
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF92A1B7)),),
                          SizedBox(
                            width: 20,
                            height: 20,
                          ),
                          PetwiseUserTextfield(textLabel: "User Name",textInput:  "Jose Ryle Andre"),


                        ]
                      ),
                    ),
                  )

                  

                ]
            ),
          )
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: (){

          },
          backgroundColor: Color(0xFFF7A433),
          shape: CircleBorder(),
          child: Icon(Icons.add, color: Colors.white,)
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: PetwiseNavbar(navbarIndex: 4)
      );
  }
}
