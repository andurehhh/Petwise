import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _nicknameController;

  @override
  void initState(){
    super.initState();

    final user = context.read<UserProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName ?? "");
    _lastNameController = TextEditingController(text: user?.lastName ?? "");
    _nicknameController = TextEditingController(text: user?.nickname ?? "");
  }

  @override
  void dispose(){
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return
      Scaffold(
        backgroundColor: Color(0xFFF8F7F6),
        extendBody: true,
        appBar: AppBar(
          leading:
          IconButton(
              onPressed: () {
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
                    GestureDetector(
                      onTap: (){},
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 72,
                            backgroundColor: Color(0xFFF7A433),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: AssetImage(
                                  'assets/images/SUA.jpg'),
                              child: CircleAvatar(
                                backgroundColor: Colors.black26,
                                radius: 70,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 20,
                      width: 40,
                    ),
                    // Text("Lady Gaga",
                    //   style: GoogleFonts.plusJakartaSans(fontSize: 23,
                    //       fontWeight: FontWeight.bold,
                    //       letterSpacing: -1.5),
                    // ),
                    Container(
                      // color: Colors.red,
                      height: 50,
                      width: 300,
                      child: TextField(
                        enabled: true,
                        textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 23,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.5),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          controller: _nicknameController,
                      ),
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
                                  PetwiseUserTextfield(textLabel: "First Name",
                                      textHint: "Enter first name", isEditable: true, controller: _firstNameController,),
                                  PetwiseUserTextfield(textLabel: "Last Name",
                                      textHint: "Enter last name", isEditable: true, controller: _lastNameController),
                                  PetwiseUserTextfield(textLabel: "Email",
                                      textHint: userProvider.user?.email, isEditable: false,),

                                  ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: 800,
                                          minWidth: 40
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: 30,
                                          ),
                                          OutlinedButton(onPressed: () {
                                            print("DEBUG Controller First: ${_firstNameController.text}");
                                            String newFirstName = _firstNameController.text;
                                            String newLastName = _lastNameController.text;
                                            String newNickname = _nicknameController.text;

                                            context.read<UserProvider>().updateUserInfo(newFirstName, newLastName, newNickname);

                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Profile Updated!"),
                                                  backgroundColor: Colors.lightGreen,)
                                            );
                                            Navigator.pop(context);
                                          },
                                              style: OutlinedButton.styleFrom(
                                                  minimumSize: const Size(
                                                      300, 50),
                                                  side: const BorderSide(
                                                      color: Color(0xFFF7A433),
                                                      width: 2
                                                  )
                                              ),
                                              child: Text("SAVE CHANGES",
                                                style: GoogleFonts
                                                    .plusJakartaSans(
                                                    color: Color(0xFFF7A433),
                                                    fontWeight: FontWeight
                                                        .bold),
                                              )
                                          ),

                                          SizedBox(
                                            width: 50,
                                            height: 15,
                                          ),
                                          FilledButton(onPressed: () {
                                            Navigator.pop(context);

                                          },
                                              style: FilledButton.styleFrom(
                                                  minimumSize: const Size(
                                                      300, 50),
                                                  backgroundColor: Color(
                                                      0xFFF7A433),
                                                  side: const BorderSide(
                                                    color: Color(0xFFDA9B44),
                                                    width: 2,
                                                  )
                                              ),
                                              child: Text("CANCEL",
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                      color: Color(0xFFFFFFFF),
                                                      fontWeight: FontWeight
                                                          .bold)
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

