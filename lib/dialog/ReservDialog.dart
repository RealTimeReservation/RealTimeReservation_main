import 'package:flutter/material.dart';
import 'package:realtime_seat_reservation/model/ReadingRoomModel.dart';
import 'package:realtime_seat_reservation/model/SeatModel.dart';

class ReservDialog {
  static void show(BuildContext context, String state,
      ReadingRoomModel readingRoomModel, int seatNumber) {
    if (state == SeatModel.Seat_Empty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            title: Column(
              children: <Widget>[
                new Text(
                  '좌석예약',
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
                  readingRoomModel.name +
                      " - " +
                      seatNumber.toString() +
                      "번 좌석을\n예약하시겠습니까?",
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
    } else if (state == SeatModel.Seat_Reserved) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            title: Column(
              children: <Widget>[
                new Text(
                  '좌석예약',
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
                  readingRoomModel.name +
                      " - " +
                      seatNumber.toString() +
                      "번 좌석은\n예약된 좌석입니다.",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        barrierDismissible: false,
      );
    } else if (state == SeatModel.Seat_Seating) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            title: Column(
              children: <Widget>[
                new Text(
                  '좌석예약',
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
                  readingRoomModel.name +
                      " - " +
                      seatNumber.toString() +
                      "번 좌석은\n사용중인 좌석입니다.",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        barrierDismissible: false,
      );
    }
  }
}
