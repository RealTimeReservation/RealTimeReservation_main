import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realtime_seat_reservation/cache/AppCache.dart';
import 'package:realtime_seat_reservation/cache/LoginCache.dart';
import 'package:realtime_seat_reservation/dialog/GuildDialog.dart';
import 'package:realtime_seat_reservation/dialog/ReservDialog.dart';
import 'package:realtime_seat_reservation/model/ReadingRoomModel.dart';
import 'package:realtime_seat_reservation/model/SeatModel.dart';
import 'package:realtime_seat_reservation/util/StringUtil.dart';

class SeatStatusWidget extends StatefulWidget {
  @override
  _SeatStatusState createState() => _SeatStatusState();
}

class _SeatStatusState extends State<SeatStatusWidget> {
  List<ReadingRoomModel> readingRoomList = [];
  late ReadingRoomModel currentReadingRoom;
  bool isReadingRoomLoading = false;
  bool isServerWriting = false;

  @override
  void initState() {
    super.initState();
    _GetReadingRoom();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Column(
            children: [
              _ReadingRoomBar(),
              _SeatStatusScreen(),
              _SeatStatusGuideWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ReadingRoomBar() {
    return Container(
      padding: EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          ReadingRoomSelectWidget(),
          Container(
            height: 50,
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: ElevatedButton(
              onPressed: () {
                int index = currentReadingRoom.number - 1;
                int prevIndex = index - 1;

                if (prevIndex < 0) {
                  return;
                } else {
                  setState(() {
                    currentReadingRoom = readingRoomList[prevIndex];
                  });
                }
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text(
                  '??????',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 112, 192, 1.0),
                    fontSize: 10,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.grey,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Color.fromRGBO(0, 112, 192, 1.0),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size(0, 0),
              ),
            ),
          ),
          Container(
            height: 50,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: ElevatedButton(
              onPressed: () {
                int index = currentReadingRoom.number - 1;
                int nextIndex = index + 1;

                if (nextIndex > readingRoomList.length - 1) {
                  return;
                } else {
                  setState(() {
                    currentReadingRoom = readingRoomList[nextIndex];
                  });
                }
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text(
                  '??????',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 112, 192, 1.0),
                    fontSize: 10,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.grey,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Color.fromRGBO(0, 112, 192, 1.0),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size(0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _GetReadingRoom() async {
    isReadingRoomLoading = false;
    await Firebase.initializeApp();
    Future<QuerySnapshot> firestore = FirebaseFirestore.instance
        .collection('ReadingRoom')
        .orderBy('number', descending: false)
        .get();
    await firestore.then((QuerySnapshot snapshot) {
      readingRoomList = snapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        return ReadingRoomModel.fromMap({
          'number': data['number'],
          'info': data['info'].toString(),
          'name': data['name'].toString(),
          'uid': document.id,
        });
      }).toList();
    });

    if (readingRoomList.length > 0) {
      currentReadingRoom = readingRoomList.first;
    } else {
      currentReadingRoom = ReadingRoomModel.fromMap({
        'number': 0,
        'info': '',
        'name': '',
        'uid': '',
      });
    }

    setState(() {
      isReadingRoomLoading = true;
    });
  }

  Stream<QuerySnapshot> _GetSeatStatusStream(String readingRoomUid) {
    Firebase.initializeApp();
    return FirebaseFirestore.instance
        .collection('ReadingRoom')
        .doc(readingRoomUid)
        .collection('Seat')
        .orderBy('number', descending: false)
        .snapshots();
  }

  Widget _SeatStatusScreen() {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;

    if (!isReadingRoomLoading) {
      return Container(
        width: width,
        height: width,
        child: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(0, 112, 192, 1.0),
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(minHeight: width),
      child: StreamBuilder<QuerySnapshot>(
        stream: _GetSeatStatusStream(currentReadingRoom.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container(
              width: width,
              height: width,
              child: Text(
                'Connection Error: ' + snapshot.error.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: width,
              height: width,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(0, 112, 192, 1.0),
                ),
              ),
            );
          }

          return Container(
            margin: EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                if (data['status'] == SeatModel.Seat_Empty) {
                  return InkWell(
                    onTap: () async {
                      bool result = await ReservDialog.show(
                        context,
                        data['status'],
                        currentReadingRoom,
                        data['number'],
                      );

                      if (result) {
                        isServerWriting = true;
                        writeReservation(document.id);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(112, 173, 71, 1.0),
                      ),
                      child: Center(
                        child: Text(
                          data['number'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (data['status'] == SeatModel.Seat_Reserved) {
                  return InkWell(
                    onTap: () {
                      ReservDialog.show(
                        context,
                        data['status'],
                        currentReadingRoom,
                        data['number'],
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(0, 112, 192, 1.0),
                      ),
                      child: Center(
                        child: Text(
                          data['number'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (data['status'] == SeatModel.Seat_Seating) {
                  return InkWell(
                    onTap: () {
                      ReservDialog.show(
                        context,
                        data['status'],
                        currentReadingRoom,
                        data['number'],
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(255, 55, 55, 1.0),
                      ),
                      child: Center(
                        child: Text(
                          data['number'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: const Center(
                      child: Text(
                        'e',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _SeatStatusGuideWidget() {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Container(
      margin: EdgeInsets.fromLTRB(20, height / 12, 20, 50),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 7),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 112, 192, 1.0),
                ),
              ),
              Text(
                ' : ????????? ??????',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 7),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 55, 55, 1.0),
                ),
              ),
              Text(
                ' : ?????? ?????? ??????',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 7),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(112, 173, 71, 1.0),
                ),
              ),
              Text(
                ' : ?????? ?????? ??????',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget ReadingRoomSelectWidget() {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;

    if (!isReadingRoomLoading) {
      return Container(
        width: width,
        height: 50,
      );
    }

    return Container(
      width: width,
      height: 50,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          alignment: Alignment.topCenter,
          iconSize: 0,
          items: readingRoomList.map<DropdownMenuItem<ReadingRoomModel>>(
              (ReadingRoomModel value) {
            return DropdownMenuItem<ReadingRoomModel>(
              value: value,
              child: Container(
                child: Center(
                  child: Text(
                    value.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return readingRoomList.map((ReadingRoomModel value) {
              return Container(
                width: width,
                margin: EdgeInsets.symmetric(horizontal: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Icon(null),
                    ),
                    Container(
                      child: Center(
                        child: Text(
                          value.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          value: currentReadingRoom,
          onChanged: (ReadingRoomModel? newValue) {
            if (currentReadingRoom.uid != newValue!.uid) {
              setState(() {
                currentReadingRoom = newValue;
              });
            }
          },
          buttonHeight: 50,
          itemHeight: 50,
        ),
      ),
    );
  }

  Future<void> writeReservation(String seatUid) async {
    CollectionReference col = FirebaseFirestore.instance
        .collection('ReadingRoom')
        .doc(currentReadingRoom.uid)
        .collection('Seat')
        .doc(seatUid)
        .collection('Reservation');

    DocumentReference seatDoc = FirebaseFirestore.instance
        .collection('ReadingRoom')
        .doc(currentReadingRoom.uid)
        .collection('Seat')
        .doc(seatUid);

    CollectionReference userCol = FirebaseFirestore.instance
        .collection('UserData')
        .doc(LoginCache.uid)
        .collection('Reservation');

    bool hasReservation = false;
    await Firebase.initializeApp();
    await userCol
        .where('expiredAt',
            isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.size != 0) {
        hasReservation = true;
      }
    }).catchError((error) {
      setState(() {
        isServerWriting = false;
        GuildDialog.show(context, '????????????', '?????? ????????? ??????????????????.');
        return;
      });
    }).timeout(Duration(seconds: 5), onTimeout: () {
      setState(() {
        isServerWriting = false;
        GuildDialog.show(context, '????????????', '?????? ????????? ??????????????????.');
        return;
      });
    });

    if (hasReservation) {
      isServerWriting = false;
      GuildDialog.show(context, '????????????', '?????? ????????? ????????? ????????????.');
      return;
    }

    await seatDoc
        .update({
          'status': SeatModel.Seat_Reserved,
          'reservPublishedAt': DateTime.now().millisecondsSinceEpoch,
        })
        .then((value) {})
        .catchError((error) {
          setState(() {
            isServerWriting = false;
            GuildDialog.show(context, '????????????', '?????? ????????? ??????????????????.');
            return;
          });
        })
        .timeout(Duration(seconds: 5), onTimeout: () {
          setState(() {
            isServerWriting = false;
            GuildDialog.show(context, '????????????', '?????? ????????? ??????????????????.');
            return;
          });
        });

    late String reservation_id;
    await col.add({
      'reservated_user_id': LoginCache.uid,
      'reservationed_time': StringUtil.DateToString(DateTime.now()),
      'delay_count': 0,
      'end_time': StringUtil.DateToString(DateTime.now()),
      'publishedAt': DateTime.now().millisecondsSinceEpoch,
      'expiredAt': DateTime.now().millisecondsSinceEpoch +
          AppCache.basicPublishedAtExpriedTime,
      'startAt': DateTime.now().millisecondsSinceEpoch,
    }).then((value) {
      reservation_id = value.id;
    }).catchError((error) {
      setState(() {
        isServerWriting = false;
        GuildDialog.show(context, '????????????', '?????? ????????? ??????????????????.');
        return;
      });
    }).timeout(Duration(seconds: 5), onTimeout: () {
      setState(() {
        isServerWriting = false;
        GuildDialog.show(context, '????????????', '?????? ????????? ??????????????????.');
        return;
      });
    });

    await userCol.add({
      'reading_room_id': currentReadingRoom.uid,
      'seat_id': seatUid,
      'reservation_id': reservation_id,
      'expiredAt': DateTime.now().millisecondsSinceEpoch +
          AppCache.basicPublishedAtExpriedTime,
    }).then((value) {
      setState(() {
        isServerWriting = false;
        GuildDialog.show(context, '????????????', '????????? ?????????????????????.');
      });
    }).catchError((error) {
      setState(() {
        isServerWriting = false;
        GuildDialog.show(context, '????????????', '?????? ????????? ??????????????????.');
      });
    }).timeout(Duration(seconds: 5), onTimeout: () {
      setState(() {
        isServerWriting = false;
        GuildDialog.show(context, '????????????', '?????? ????????? ??????????????????.');
      });
    });
  }
}
