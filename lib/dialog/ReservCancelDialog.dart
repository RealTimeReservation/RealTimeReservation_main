import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:realtime_seat_reservation/model/ReadingRoomModel.dart';
import 'package:realtime_seat_reservation/model/SeatModel.dart';

class ReservCancelDialog {
  static Future<bool> show(
      BuildContext context, String readingRoomName, int seatNumber) async {
    bool result = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Column(
            children: const <Widget>[
              Text(
                '취소하기',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                readingRoomName +
                    " - " +
                    seatNumber.toString() +
                    "번 좌석을\n취소하시겠습니까?",
                style: TextStyle(color: Colors.black, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      result = true;
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(0, 112, 192, 1.0),
                      onPrimary: Color.fromARGB(255, 0, 80, 138),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      result = false;
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: Text(
                        '아니오',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(127, 127, 127, 1.0),
                      onPrimary: Color.fromARGB(255, 83, 83, 83),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
    return result;
  }
}
