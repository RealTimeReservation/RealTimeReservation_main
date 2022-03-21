import 'package:intl/intl.dart';

class StringUtil {
  static String DateToString(DateTime dateTime) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    return formattedDate;
  }
}
