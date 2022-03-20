import 'dart:convert';

import 'package:crypto/crypto.dart';

class LoginUtil {
  static String StringToSHA256(String s) {
    var key = utf8.encode(s);
    var bytes = utf8.encode("foobar");

    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);

    return digest.toString();
  }
}
