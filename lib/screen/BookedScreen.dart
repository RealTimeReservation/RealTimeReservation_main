import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:realtime_seat_reservation/cache/AppCache.dart';
import 'package:realtime_seat_reservation/cache/LoginCache.dart';
import 'package:realtime_seat_reservation/dialog/GuildDialog.dart';
import 'package:realtime_seat_reservation/dialog/ReservCancelDialog.dart';
import 'package:realtime_seat_reservation/dialog/ReservDelayDialog.dart';
import 'package:realtime_seat_reservation/model/QRModel.dart';
import 'package:realtime_seat_reservation/model/ReservationModel.dart';
import 'package:realtime_seat_reservation/model/SeatModel.dart';
import 'package:realtime_seat_reservation/util/StringUtil.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class BookedScreen extends StatefulWidget {
  late ReservationModel reservationModel;
  BookedScreen({required this.reservationModel});

  _BookedState createState() =>
      _BookedState(reservationModel: reservationModel);
}

class _BookedState extends State<BookedScreen> {
  late ReservationModel reservationModel;
  _BookedState({required this.reservationModel});

  String _qrOutput = '';
  bool isOver = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 33,
          ),
          color: Colors.black,
        ),
        title: Text(
          '나의 예약',
          style: TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Column(
                children: [
                  BookTimeBoard(),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ExtendButton(),
                    CancelButton(),
                  ]),
                  SitDownButton(),
                  UnderInfo(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String BookedTimer(BuildContext context) {
    int now = DateTime.now().millisecondsSinceEpoch;
    int reserveEndTime =
        reservationModel.publishedAt + AppCache.basicPublishedAtExpriedTime;
    int seatingEndTime = reservationModel.expiredAt;
    int remainMin = 60 - ((reserveEndTime - now) / 1000).floor() ~/ 60;
    DateTime reserveTime =
        DateTime.fromMillisecondsSinceEpoch(reservationModel.publishedAt);
    String current_ST = DateFormat("HH:mm").format(DateTime.now());
    String reserveTime_ST = DateFormat("HH:mm").format(reserveTime);
    DateTime endTime_DT = DateTime.fromMillisecondsSinceEpoch(seatingEndTime);
    String endTime_ST = DateFormat("HH:mm").format(endTime_DT);

    if (reservationModel.status == SeatModel.Seat_Seating) {
      if (now >= seatingEndTime) {
        isOver = true;
        return '좌석 시간이 만료되었습니다.';
      }
      return '종료시간 ( $current_ST / $endTime_ST )';
    } else if (reservationModel.status == SeatModel.Seat_Reserved) {
      if (now >= reserveEndTime) {
        isOver = true;
        return '좌석 시간이 만료되었습니다.';
      }
      return '예약한 시간 $reserveTime_ST \n 착석하기까지 남은 시간 ( $remainMin분 / 60분)';
    } else {
      return '예약된 정보가 없습니다.';
    }
  }

  String ExtensionTimer() {
    int extensiontime =
        reservationModel.expiredAt + AppCache.basicReservatedDelayTime;
    DateTime reserveTime =
        DateTime.fromMillisecondsSinceEpoch(reservationModel.expiredAt);
    String reserveTime_ST = DateFormat("HH:mm").format(reserveTime);
    DateTime extensionTime_DT =
        DateTime.fromMillisecondsSinceEpoch(extensiontime);
    String extensionTime_ST = DateFormat("HH:mm").format(extensionTime_DT);
    return '$reserveTime_ST -> $extensionTime_ST';
  }

  Widget BookTimeBoard() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 60, 0, 20),
      child: TimerBuilder.periodic(
        Duration(minutes: 1),
        builder: (context) {
          String text = BookedTimer(context);

          return Container(
            child: Text(
              BookedTimer(context),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
          );
        },
      ),
    );
  }

  Widget ExtendButton() {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Container(
      width: width / 2,
      height: width / 2 - 30,
      padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
      child: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            primary: Color.fromRGBO(0, 112, 192, 1.0),
          ),
          onPressed: () async {
            if (isOver) {
              GuildDialog.show(context, '연장하기', '좌석 시간이 만료된 자리입니다.');
            } else if (reservationModel.status !=
                ReservationModel.Seat_Seating) {
              GuildDialog.show(context, '연장하기', '아직 착석하지 않은 자리입니다.');
            } else {
              if (reservationModel.delay_count >= 3) {
                GuildDialog.show(
                    context, '연장하기', '연장하기 횟수가 초과되었습니다.\n더 이상 연장할 수 없습니다.');
              } else {
                bool dialogResult = await ReservDelayDialog.show(
                    context,
                    reservationModel.readingRoomName,
                    reservationModel.seatNum,
                    ExtensionTimer(),
                    reservationModel.delay_count);

                if (dialogResult) {
                  bool delayResult = await delayExpired(context);
                  if (delayResult) {
                    getReservation();
                  }
                }
              }
            }
          },
          child: Text(
            '연장하기',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget CancelButton() {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Container(
      width: width / 2,
      height: width / 2 - 30,
      padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
      child: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            primary: Color.fromRGBO(127, 127, 127, 1.0),
          ),
          onPressed: () async {
            if (isOver) {
              GuildDialog.show(context, '연장하기', '좌석 시간이 만료된 자리입니다.');
            } else if (reservationModel.status ==
                    ReservationModel.Seat_Reserved ||
                reservationModel.status == ReservationModel.Seat_Seating) {
              bool dialogResult = await ReservCancelDialog.show(context,
                  reservationModel.readingRoomName, reservationModel.seatNum);

              if (dialogResult) {
                bool result = await cancelReservation(context);
                if (result) {
                  Navigator.pop(context);
                } else {
                  GuildDialog.show(context, '취소하기', '서버 연결에 실패했습니다.');
                }
              }
            }
          },
          child: Text(
            '취소하기',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget SitDownButton() {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    if (reservationModel.status == ReservationModel.Seat_Reserved) {
      return Container(
        width: width,
        padding: EdgeInsets.all(20),
        child: SizedBox(
          height: 60,
          width: double.maxFinite,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              primary: Color.fromRGBO(0, 112, 192, 1.0),
            ),
            onPressed: () async {
              if (isOver) {
                GuildDialog.show(context, '연장하기', '좌석 시간이 만료된 자리입니다.');
              } else {
                bool qrResult = await _scan(context);
                if (qrResult) {
                  getReservation();
                }
              }
            },
            child: Text(
              '착석하기',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      );
    } else if (reservationModel.status == ReservationModel.Seat_Seating) {
      return Container(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          height: 60,
          width: 330,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              primary: Colors.grey,
            ),
            onPressed: () {},
            child: Text(
              '착석완료',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          height: 60,
          width: 330,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              primary: Colors.grey,
            ),
            onPressed: () {},
            child: Text(
              '예약없음',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      );
    }
  }

  Widget UnderInfo() {
    return Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            '나의 예약 좌석',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          Text(
            reservationModel.readingRoomName +
                " " +
                reservationModel.seatNum.toString() +
                "번",
            style: TextStyle(
              color: Color.fromARGB(255, 116, 116, 116),
              fontSize: 16,
            ),
          )
        ]));
  }

  Future<void> getReservation() async {
    bool isReserve = false;
    ReservationModel result = ReservationModel();

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
                'startAt': DateTime.now().millisecondsSinceEpoch,
              });

              result = true;
            }
          }
        });

        await FirebaseFirestore.instance
            .collection('UserData')
            .doc(LoginCache.uid)
            .collection('Reservation')
            .where('reservation_id', isEqualTo: reservationModel.reservationId)
            .get()
            .then((QuerySnapshot snapshot) {
          if (snapshot.size > 0) {
            snapshot.docs.first.reference.update({
              'expiredAt': DateTime.now().millisecondsSinceEpoch +
                  AppCache.basicReservatedExpriedTime,
            });
          }
        });
      }
    } catch (e) {
      _qrOutput = "";
      GuildDialog.show(context, '착석하기', 'QR이 잘못되었습니다.');
    }
    return result;
  }

  Future<bool> delayExpired(BuildContext context) async {
    bool result = false;

    await Firebase.initializeApp();
    DocumentReference doc = FirebaseFirestore.instance
        .collection('ReadingRoom')
        .doc(reservationModel.readingRoomId)
        .collection('Seat')
        .doc(reservationModel.seatId)
        .collection('Reservation')
        .doc(reservationModel.reservationId);

    await doc.update({
      'delay_count': reservationModel.delay_count + 1,
      'end_time': StringUtil.MillisecondsToString(
          reservationModel.expiredAt + AppCache.basicReservatedDelayTime),
      'expiredAt':
          reservationModel.expiredAt + AppCache.basicReservatedDelayTime,
    }).then((value) {
      result = true;
    }).onError((error, stackTrace) {
      GuildDialog.show(context, '연장하기', '서버 연결에 실패했습니다.');
      result = false;
    });

    await FirebaseFirestore.instance
        .collection('UserData')
        .doc(LoginCache.uid)
        .collection('Reservation')
        .where('reservation_id', isEqualTo: reservationModel.reservationId)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.size > 0) {
        snapshot.docs.first.reference.update({
          'expiredAt':
              reservationModel.expiredAt + AppCache.basicReservatedDelayTime,
        });
      }
    });

    return result;
  }

  Future<bool> cancelReservation(BuildContext context) async {
    bool result = false;

    await Firebase.initializeApp();
    await FirebaseFirestore.instance
        .collection('ReadingRoom')
        .doc(reservationModel.readingRoomId)
        .collection('Seat')
        .doc(reservationModel.seatId)
        .collection('Reservation')
        .doc(reservationModel.reservationId)
        .delete()
        .then((value) {
      result = true;
    }).onError((error, stackTrace) {
      result = false;
    });

    if (!result) {
      return result;
    }
    result = false;

    await FirebaseFirestore.instance
        .collection('ReadingRoom')
        .doc(reservationModel.readingRoomId)
        .collection('Seat')
        .doc(reservationModel.seatId)
        .update({
      'status': SeatModel.Seat_Empty,
      'reservPublishedAt': 0,
    }).then((value) {
      result = true;
    }).onError((error, stackTrace) {
      result = false;
    });

    if (!result) {
      return result;
    }
    result = false;

    await FirebaseFirestore.instance
        .collection('UserData')
        .doc(LoginCache.uid)
        .collection('Reservation')
        .get()
        .then((QuerySnapshot snapshot) {
      for (DocumentSnapshot docSnap in snapshot.docs) {
        docSnap.reference.delete();
      }
      result = true;
    }).onError((error, stackTrace) {
      result = false;
    });

    return result;
  }
}
