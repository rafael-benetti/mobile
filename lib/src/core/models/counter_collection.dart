class CounterPhoto {
  String key;
  String downloadUrl;

  CounterPhoto.fromMap(Map<String, dynamic> json) {
    key = json['key'];
    downloadUrl = json['downloadUrl'];
  }
}

class CounterCollection {
  String counterId;
  String counterTypeId;
  String counterTypeLabel;
  double mechanicalCount;
  double digitalCount;
  double userCount;
  double telemetryCount;
  List<dynamic> photos = [];

  CounterCollection(String cId, bool hasDigital, bool hasMechanical,
      bool countable, String cTypeLabel) {
    counterId = cId;
    counterTypeLabel = cTypeLabel;
    if (!hasDigital) {
      digitalCount = -1;
    }
    if (!hasMechanical) {
      mechanicalCount = -1;
    }
    if (!countable) {
      userCount = -1;
    }
  }

  CounterCollection.fromMap(Map<String, dynamic> json) {
    counterId = json['counterId'];
    counterTypeLabel = json['counterTypeLabel'];
    mechanicalCount = json['mechanicalCount'] != null
        ? json['mechanicalCount'].toDouble()
        : null;
    digitalCount =
        json['digitalCount'] != null ? json['digitalCount'].toDouble() : null;
    userCount = json['userCount'] != null ? json['userCount'].toDouble() : null;
    telemetryCount = json['telemetryCount'] != null
        ? json['telemetryCount'].toDouble()
        : null;
    photos = json['photos'] != null
        ? List<dynamic>.from(
            json['photos'].map((photo) => CounterPhoto.fromMap(photo)).toList())
        : [];
  }

  Map<String, dynamic> toMap(bool editing) {
    var result = {
      'counterId': counterId,
      'counterTypeLabel': counterTypeLabel,
      'mechanicalCount': mechanicalCount,
      'digitalCount': digitalCount,
      'userCount': userCount,
    };
    if (!editing) {
      if (result['mechanicalCount'] == -1) {
        result.remove('mechanicalCount');
      }
      if (result['digitalCount'] == -1) {
        result.remove('digitalCount');
      }
      if (result['userCount'] == -1) {
        result.remove('userCount');
      }
    } else {
      if (result['mechanicalCount'] == null) {
        result.remove('mechanicalCount');
      }
      if (result['digitalCount'] == null) {
        result.remove('digitalCount');
      }
      if (result['userCount'] == null) {
        result.remove('userCount');
      }
    }
    return result;
  }
}
