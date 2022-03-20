import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realtime_seat_reservation/util/LoginUtil.dart';
import 'package:realtime_seat_reservation/widget/login/LoginWidget.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          width: width,
          height: height,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'res/images/school_logo.jpg',
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                LoginWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
