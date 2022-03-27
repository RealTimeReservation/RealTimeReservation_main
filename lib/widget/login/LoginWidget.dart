import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realtime_seat_reservation/cache/LoginCache.dart';
import 'package:realtime_seat_reservation/model/UserModel.dart';
import 'package:realtime_seat_reservation/screen/MainScreen.dart';
import 'package:realtime_seat_reservation/util/LoginUtil.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool isAccountMatch = false;
  bool isLoginClick = false;

  String idInput = '';
  String pwInput = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 60),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (text) {
                idInput = text.toString();
              },
              onTap: () {},
              enabled: true,
              style: const TextStyle(
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                labelText: 'ID',
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
                floatingLabelStyle: TextStyle(
                  color: Color.fromRGBO(0, 112, 192, 1.0),
                ),
                hintText: 'Enter your email',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (text) {
                pwInput = text;
              },
              onTap: () {},
              enabled: true,
              style: TextStyle(
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
                floatingLabelStyle: TextStyle(
                  color: Color.fromRGBO(0, 112, 192, 1.0),
                ),
                hintText: 'Enter your Password',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Text(
              LoginGuide(),
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await AccountValidation(idInput, pwInput)
                          .then((connectionResult) {
                        isAccountMatch = connectionResult;
                      });
                      setState(() {
                        isLoginClick = true;
                      });

                      if (isAccountMatch) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen()),
                            (route) => false);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text(
                        '로그인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(0, 112, 192, 1.0),
                      onPrimary: Color.fromARGB(255, 0, 80, 138),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String LoginGuide() {
    if (isLoginClick) {
      if (idInput.isEmpty) {
        return '아이디를 입력해 주십시오.';
      } else if (pwInput.isEmpty) {
        return '비밀번호를 입력해 주십시오.';
      } else if (!isAccountMatch) {
        return '로그인 정보가 일치하지 않습니다.';
      }
    }
    return '';
  }

  Future<bool> AccountValidation(String id, String pw) async {
    UserModel? userData;

    await Firebase.initializeApp();
    Future<QuerySnapshot> firestore = FirebaseFirestore.instance
        .collection('UserData')
        .where('id', isEqualTo: idInput)
        .get();
    await firestore.then((QuerySnapshot snapshot) {
      if (snapshot.size == 1) {
        userData = UserModel.fromMap({
          'id': snapshot.docs.first.get('id').toString(),
          'password': snapshot.docs.first.get('password').toString(),
          'uid': snapshot.docs.first.id,
        });
      }
    });

    if (userData != null) {
      if (userData!.id == idInput &&
          userData!.password == LoginUtil.StringToSHA256(pwInput)) {
        LoginCache.id = userData!.id;
        LoginCache.uid = userData!.uid;
        return true;
      }
    }
    return false;
  }
}
