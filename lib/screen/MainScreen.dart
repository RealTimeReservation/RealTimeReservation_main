import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realtime_seat_reservation/screen/ReservScreen.dart';

class MainScreen extends StatefulWidget {
  _MainState createState() => _MainState();
}

class _MainState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReservScreen()));
                    },
                    child: Text('예약하기'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('나의 에약'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
