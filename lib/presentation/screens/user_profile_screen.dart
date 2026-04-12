import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:petwise/presentation/widgets/petwise_Navbar.dart';

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
                      height: 100,
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(20),
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
