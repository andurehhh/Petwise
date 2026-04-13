import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/presentation/widgets/petwise_Navbar.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/routes/app_route.dart';

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
                          backgroundImage: AssetImage('assets/images/SUA.jpg'),
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
                              onPressed: (){
                                Navigator.pushNamed(context, AppRoute.editUserProfile);
                              },
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
                  Text("Lady Gaga",
                  style: GoogleFonts.plusJakartaSans(fontSize: 23, fontWeight: FontWeight.bold, letterSpacing: -1.5),
                  ),
                  SizedBox(
                    width: 10,
                      height: 5,
                  ),
                  Container(
                    width: 150,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCDCDC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("USER INFORMATION",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xFF92A1B7),

                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                              ),
                              PetwiseUserTextfield(textLabel: "First Name",textInput:  "Yves Kylle Genesis"),
                              PetwiseUserTextfield(textLabel: "Last Name",textInput:  "Almazora"),
                              PetwiseUserTextfield(textLabel: "Email",textInput:  "andrealmazora19@gmail.com"),

                                  ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: 800,
                                          minWidth: 40
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: 30,
                                          ),
                                          OutlinedButton(onPressed: (){},
                                              style: OutlinedButton.styleFrom(
                                                  minimumSize: const Size(300, 50),
                                                  side: const BorderSide(
                                                      color: Color(0xFFF7A433),
                                                      width: 2
                                                  )
                                              ),
                                              child: Text("FORGOT PASSWORD",
                                                style: GoogleFonts.plusJakartaSans(
                                                    color: Color(0xFFF7A433),
                                                    fontWeight: FontWeight.bold),
                                              )
                                          ),

                                          SizedBox(
                                            width: 50,
                                            height: 15,
                                          ),
                                          FilledButton(onPressed: (){},
                                              style: FilledButton.styleFrom(
                                                minimumSize: const Size(300,50),
                                                backgroundColor: Color(0xFFF7A433),
                                                side: const BorderSide(
                                                  color: Color(0xFFDA9B44),
                                                  width: 2,
                                                )
                                              ),
                                              child: Text("LOG OUT",
                                                style: GoogleFonts.plusJakartaSans(
                                                    color: Color(0xFFFFFFFF),
                                                    fontWeight: FontWeight.bold)
                                              )
                                          )
                                        ],
                                      ))

                            ]
                          ),
                        ],
                      ),
                    ),
                  )

                  

                ]
            ),
          )
        ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: (){
        //
        //   },
        //   backgroundColor: Color(0xFFF7A433),
        //   shape: CircleBorder(),
        //   child: Icon(Icons.add, color: Colors.white,)
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // bottomNavigationBar: PetwiseNavbar(navbarIndex: 4)
      );
  }
}
