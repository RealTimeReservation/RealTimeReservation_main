class SeatModel {
  static String Seat_Empty = 'Empty';
  static String Seat_Reserved = 'Reserved';
  static String Seat_Seating = 'Seating';

  final int number;
  final String status;

  SeatModel.fromMap(Map<String, dynamic> map)
      : number = map['number'],
        status = map['status'];
}
