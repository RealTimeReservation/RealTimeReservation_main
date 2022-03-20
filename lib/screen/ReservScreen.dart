import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realtime_seat_reservation/widget/reserv/SeatStatusWidget.dart';

class ReservScreen extends StatefulWidget {
  @override
  _ReservState createState() => _ReservState();
}

class _ReservState extends State<ReservScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          constraints: BoxConstraints(),
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
        ),
        title: Text(
          '예약하기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              SeatStatusWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
