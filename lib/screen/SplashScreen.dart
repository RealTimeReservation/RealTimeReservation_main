import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Container(
          margin: EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'res/images/white_hexagon.png',
                      width: 120,
                      height: 110,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'L',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 50),
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  'Logo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
