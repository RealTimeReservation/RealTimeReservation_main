import 'dart:async';

import 'package:flutter/material.dart';
import 'package:realtime_seat_reservation/screen/LoginScreen.dart';
import 'package:realtime_seat_reservation/screen/SplashScreen.dart';

void main() {
  runApp(MaterialApp(
    home: const RealtimeSeatReservationMain(),
  ));
}

class RealtimeSeatReservationMain extends StatelessWidget {
  const RealtimeSeatReservationMain({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
    });

    return MaterialApp(
      title: 'ReadingRoom',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color.fromRGBO(0, 112, 192, 1.0),
        primaryColorDark: Color.fromARGB(255, 0, 80, 138),
      ),
      home: SplashScreen(),
    );
  }
}
