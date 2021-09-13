class Notification {
  String machineId;
  String groupId;
  String title;
  String body;
  DateTime date;

  Notification.fromMap(Map<String, dynamic> json) {
    machineId = json['machineId'];
    groupId = json['groupId'];
    title = json['title'];
    body = json['body'];
    date = DateTime.parse(json['date']);
  }
}
