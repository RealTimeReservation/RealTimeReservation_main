import 'package:intl/intl.dart';

class StringUtil {
  static String DateToString(DateTime dateTime) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    return formattedDate;
  }

  static String DateToStringUntilHour(DateTime dateTime) {
    String formattedDate = DateFormat('HH:mm').format(dateTime);

    return formattedDate;
  }

  static String MillisecondsToString(int milliseconds) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.fromMillisecondsSinceEpoch(milliseconds));

    return formattedDate;
  }
}
