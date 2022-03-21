import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;

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
                    _scan();
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

  Future<void> _scan() async {
    String? qr_value = await scanner.scan();
    try {
      _qrOutput = qr_value!;
      print("QR OUTPUT VALUE: " + _qrOutput);
    } catch (e) {
      _qrOutput = "";
    }
  }
}
