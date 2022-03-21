class QRModel {
  late String data; // serviceId-readingRoomId-seatId
  late String readingRoomId;
  late String seatId;

  QRModel(String data) {
    this.data = data;
    List<String> data_split = data.split('-');
    readingRoomId = data_split[1];
    seatId = data_split[2];
  }
}
