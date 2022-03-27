class ReadingRoomModel {
  final int number;
  final String info;
  final String name;
  final String uid;

  ReadingRoomModel.fromMap(Map<String, dynamic> map)
      : number = map['number'],
        info = map['info'],
        name = map['name'],
        uid = map['uid'];
}
