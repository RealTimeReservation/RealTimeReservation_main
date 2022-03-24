class ReservationModel {
  static String Seat_Empty = 'Empty';
  static String Seat_Reserved = 'Reserved';
  static String Seat_Seating = 'Seating';
  static String None_Reserve = 'None';

  late int delay_count;
  late String end_time;
  late int expiredAt;
  late int startAt;
  late int publishedAt;
  late String reservationed_time;
  late String status;
  late String readingRoomId;
  late String seatId;
  late String reservationId;
  late String readingRoomName;
  late int seatNum;

  ReservationModel() {
    delay_count = 0;
    end_time = '';
    expiredAt = 0;
    startAt = 0;
    publishedAt = 0;
    reservationed_time = '';
    status = None_Reserve;
    reservationId = '';
    readingRoomId = '';
    seatId = '';
    readingRoomName = '';
    seatNum = 0;
  }

  void reset() {
    delay_count = 0;
    end_time = '';
    expiredAt = 0;
    startAt = 0;
    publishedAt = 0;
    reservationed_time = '';
    status = None_Reserve;
    reservationId = '';
    readingRoomId = '';
    seatId = '';
    readingRoomName = '';
    seatNum = 0;
  }

  @override
  String toString() {
    return 'delay_count: $delay_count - ' +
        'end_time: $end_time - ' +
        'expiredAt: $expiredAt - ' +
        'startAt: $startAt - ' +
        'publishedAt: $publishedAt - ' +
        'reservationed_time: $reservationed_time - ' +
        'status: $status - ' +
        'reservationId: $reservationId - ' +
        'readingRoomId: $readingRoomId - ' +
        'seatId: $seatId - ' +
        'readingRoomName: $readingRoomName - ' +
        'seatNum: $seatNum - ';
  }
}
