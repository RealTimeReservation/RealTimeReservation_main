import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:realtime_seat_reservation/cache/AppCache.dart';
import 'package:realtime_seat_reservation/cache/LoginCache.dart';
import 'package:realtime_seat_reservation/dialog/GuildDialog.dart';
import 'package:realtime_seat_reservation/dialog/ReservDelayDialog.dart';
import 'package:realtime_seat_reservation/model/QRModel.dart';
import 'package:realtime_seat_reservation/model/SeatModel.dart';
import 'package:realtime_seat_reservation/util/StringUtil.dart';

class BookedScreen extends StatelessWidget {
  String _qrOutput = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    _scan(context);
                  },
                  child: Text('착석 하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _scan(BuildContext context) async {
    bool result = false;
    String? qr_value = await scanner.scan();
    try {
      _qrOutput = qr_value!;
      QRModel qrData = new QRModel(qr_value);

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('ReadingRoom')
          .doc(qrData.readingRoomId)
          .collection('Seat')
          .doc(qrData.seatId);

      CollectionReference colRef = docRef.collection('Reservation');

      late String reservation_id;

      await Firebase.initializeApp();
      await colRef
          .where("reservated_user_id", isEqualTo: LoginCache.uid)
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.size == 0) {
          GuildDialog.show(context, '착석하기', '예약된 정보가 없습니다.');
        } else {
          reservation_id = snapshot.docs.first.id;
          result = true;
        }
      });

      if (result) {
        result = false;
        CollectionReference userColRef = FirebaseFirestore.instance
            .collection('UserData')
            .doc(LoginCache.uid)
            .collection('Reservation');

        await userColRef
            .where('reservation_id', isEqualTo: reservation_id)
            .get()
            .then((QuerySnapshot snapshot) async {
          if (snapshot.size == 0) {
            GuildDialog.show(context, '착석하기', '예약된 정보가 없습니다.');
          } else {
            String seatStatus = await docRef.get().then((value) {
              return value.get('status');
            });

            if (seatStatus == SeatModel.Seat_Empty) {
              GuildDialog.show(context, '착석하기', '예약된 정보가 없습니다.');
            } else if (seatStatus == SeatModel.Seat_Seating) {
              GuildDialog.show(context, '착석하기', '이미 착석한 자리입니다.');
            } else if (seatStatus == SeatModel.Seat_Reserved) {
              await docRef.update({
                'status': SeatModel.Seat_Seating,
              });
              await colRef.doc(reservation_id).update({
                'end_time': StringUtil.MillisecondsToString(
                  DateTime.now().millisecondsSinceEpoch +
                      AppCache.basicReservatedExpriedTime,
                ),
                'expiredAt': DateTime.now().millisecondsSinceEpoch +
                    AppCache.basicReservatedExpriedTime,
              });

              result = true;
            }
          }
        });
      }
    } catch (e) {
      _qrOutput = "";
      GuildDialog.show(context, '착석하기', 'QR이 잘못되었습니다.');
    }
    return result;
  }
}
