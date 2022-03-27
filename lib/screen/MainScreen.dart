import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:realtime_seat_reservation/cache/AppCache.dart';
import 'package:realtime_seat_reservation/cache/LoginCache.dart';
import 'package:realtime_seat_reservation/dialog/GuildDialog.dart';
import 'package:realtime_seat_reservation/model/ReservationModel.dart';
import 'package:realtime_seat_reservation/screen/BookedScreen.dart';
import 'package:realtime_seat_reservation/screen/ReservScreen.dart';
import 'package:timer_builder/timer_builder.dart';

class MainScreen extends StatefulWidget {
  _MainState createState() => _MainState();
}

class _MainState extends State<MainScreen> {
  late ReservationModel reservationModel = ReservationModel();
  bool timeAnchor = false;

  @override
  void initState() {
    super.initState();
    getReservation();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: <Widget>[
              Image.asset(
                'res/images/banner.png',
                height: 45,
              )
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                size: 35,
              ),
              onPressed: () {},
              color: Colors.black,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              image: AssetImage('res/images/main_background.png'),
              opacity: 0.6,
            ),
          ),
          child: Column(
            children: [
              timer(),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ReserverButton(),
                      BookedButton(),
                    ],
                  ),
                  UnderGuide()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget BookedButton() {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
      margin: EdgeInsets.only(top: 20),
      width: width / 2,
      height: width / 2 - 30,
      child: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            primary: Color.fromRGBO(0, 112, 192, 1.0),
          ),
          child: Text(
            '나의예약',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () async {
            if (reservationModel.status == ReservationModel.None_Reserve) {
              GuildDialog.show(context, '나의예약', '예약된 좌석이 없습니다.');
            } else {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookedScreen(
                    reservationModel: reservationModel,
                  ),
                ),
              );
              getReservation();
            }
          },
        ),
      ),
    );
  }

  Widget ReserverButton() {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
      margin: EdgeInsets.only(top: 20),
      width: width / 2,
      height: width / 2 - 30,
      child: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            primary: Color.fromRGBO(0, 112, 192, 1.0),
          ),
          child: Text(
            '예약하기',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservScreen(),
              ),
            );
            getReservation();
          },
        ),
      ),
    );
  }

  Widget UnderGuide() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 50, 20, 0),
      child: const Text(
        '예약을 할 시 예약하게 된 시간으로부터 1시간 이내에 \n 자리에 착석하지 않으면 자동으로 취소됩니다.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: Color.fromARGB(255, 90, 90, 90),
        ),
      ),
    );
  }

  Future<void> getReservation() async {
    print('getReservation');
    timeAnchor = false;
    bool isReserve = false;
    ReservationModel result = ReservationModel();
    reservationModel.reset();

    CollectionReference userCol = FirebaseFirestore.instance
        .collection('UserData')
        .doc(LoginCache.uid)
        .collection('Reservation');
    await Firebase.initializeApp();

    await userCol
        .where('expiredAt',
            isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .get()
        .then((QuerySnapshot userRefSnapshot) {
      if (userRefSnapshot.size == 0) {
        result.status = ReservationModel.None_Reserve;
        isReserve = false;
      } else {
        result.readingRoomId =
            userRefSnapshot.docs.first.get('reading_room_id');
        result.seatId = userRefSnapshot.docs.first.get('seat_id');
        result.reservationId = userRefSnapshot.docs.first.get('reservation_id');
        isReserve = true;
      }
    });

    if (isReserve) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('ReadingRoom')
          .doc(result.readingRoomId);

      await docRef.get().then((value) {
        result.readingRoomName = value.get('name');
      });

      docRef = docRef.collection('Seat').doc(result.seatId);
      await docRef.get().then((value) {
        result.seatNum = value.get('number');
        result.status = value.get('status');
      });

      if (result.status != ReservationModel.None_Reserve) {
        docRef = docRef.collection('Reservation').doc(result.reservationId);
        await docRef.get().then((value) {
          result.delay_count = value.get('delay_count');
          result.end_time = value.get('end_time');
          result.expiredAt = value.get('expiredAt');
          result.publishedAt = value.get('publishedAt');
          result.reservationed_time = value.get('reservationed_time');
          result.startAt = value.get('startAt');
        });
      }

      setState(() {
        reservationModel = result;
      });
    }
  }

  String IDTimeScreen() {
    int now = DateTime.now().millisecondsSinceEpoch;
    int remaintime = reservationModel.publishedAt +
        AppCache.basicPublishedAtExpriedTime -
        now;

    remaintime = (remaintime / 1000).floor();
    int remainMin = remaintime ~/ 60;
    int remainSec = remaintime % 60;

    if (reservationModel.status == ReservationModel.Seat_Reserved) {
      if (remainMin < 0 || (remainMin == 0 && remainSec == 0)) {
        reservationModel.reset();
        timeAnchor = true;
        return LoginCache.id + '님 환영합니다!\n착석 시간이 만료되었습니다: 00:00';
      } else {
        return LoginCache.id +
            '님 환영합니다!\n착석까지 남은 시간: ' +
            NumberFormat('00').format(remainMin) +
            ":" +
            NumberFormat('00').format(remainSec);
      }
    } else if (reservationModel.status == ReservationModel.None_Reserve ||
        reservationModel.status == ReservationModel.Seat_Empty) {
      if (timeAnchor) {
        return LoginCache.id + '님 환영합니다!\n착석 시간이 만료되었습니다: 00:00';
      }
      return LoginCache.id + '님 환영합니다!\n';
    } else if (reservationModel.status == ReservationModel.Seat_Seating) {
      if (remainMin < 0 || (remainMin == 0 && remainSec == 0)) {
        reservationModel.reset();
        timeAnchor = true;
        return LoginCache.id + '님 환영합니다!\n이용 시간이 만료되었습니다.';
      } else {
        return LoginCache.id +
            '님 환영합니다!\n착석한 자리: ' +
            reservationModel.readingRoomName +
            ' ' +
            reservationModel.seatNum.toString() +
            '번';
      }
    }
    return '';
  }

  Widget timer() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
        return Text(
          IDTimeScreen(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        );
      }),
    );
  }
}
