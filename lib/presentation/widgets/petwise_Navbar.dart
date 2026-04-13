import 'package:flutter/material.dart';
import 'package:petwise/routes/app_route.dart';

class PetwiseNavbar extends StatelessWidget {
  final int navbarIndex;

  const PetwiseNavbar({
    super.key,
    required this.navbarIndex
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 15,
      shadowColor: Colors.grey,
      notchMargin: 8,
      color: Colors.white,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(40)
          )
        ),
        CircleBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: (){
              Navigator.pushReplacementNamed(context, AppRoute.userProfile);
            },
            icon: Icon(
              Icons.home,
              color: Color(0xFF94A3B8),
            ),
          ),
          IconButton(
            onPressed: (){
              Navigator.pushReplacementNamed(context, AppRoute.userProfile);
            },
            icon: Icon(
              Icons.bar_chart,
              color: Color(0xFF94A3B8),
            ),
          ),
          SizedBox(
            width: 50,
          ),
          IconButton(
            onPressed: (){
              Navigator.pushReplacementNamed(context, AppRoute.userProfile);
            },
            icon: Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF94A3B8),
            ),
          ),
          IconButton(
            onPressed: (){
              Navigator.pushReplacementNamed(context, AppRoute.userProfile);
            },
            icon: Icon(
              Icons.pets,
              color: navbarIndex == 4 ? Color(0xFFF7A433) : Color(0xFF94A3B8),
            ),
          )

        ]
      ),
    );
  }
}
