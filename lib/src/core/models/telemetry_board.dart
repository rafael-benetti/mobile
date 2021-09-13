class TelemetryBoard {
  int id;
  String ownerId;
  String groupId;
  String machineId;
  String machineSerialNumber;
  String lastConnection;
  String connectionStrength;
  String connectionType;

  TelemetryBoard.fake();

  TelemetryBoard.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    groupId = json['groupId'];
    machineId = json['machineId'];
    if (machineId != null && json['machine'] != machineId) {
      machineSerialNumber = json['machine']['serialNumber'];
    }
    lastConnection = json['lastConnection'];
    connectionStrength = json['connectionSignal'];
    connectionType = json['connectionType'];
  }
}
