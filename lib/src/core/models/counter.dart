class Counter {
  String id;
  String counterTypeId;
  bool hasMechanical;
  bool hasDigital;
  String pin;

  Counter() {
    hasDigital = false;
    hasMechanical = false;
  }

  bool isEmpty() {
    if (counterTypeId == null) {
      return true;
    }
    return false;
  }

  Counter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    counterTypeId = json['counterTypeId'];
    hasMechanical = json['hasMechanical'];
    hasDigital = json['hasDigital'];
    pin = json['pin'];
  }

  Map<String, dynamic> checkMissingFields() {
    if (counterTypeId == null) {
      return {'allIsFilled': false, 'uncompleteField': 'tipo do contador'};
    }
    if (pin == null) {
      return {'allIsFilled': false, 'uncompleteField': 'telemetria'};
    }
    return {'allIsFilled': true};
  }

  Map<String, dynamic> toMap([bool creatingMachine]) {
    var result = {
      'id': id,
      'counterTypeId': counterTypeId,
      'hasMechanical': hasMechanical,
      'hasDigital': hasDigital,
      'pin': pin
    };
    if (id == null || (creatingMachine != null && creatingMachine)) {
      result.remove('id');
    }
    return result;
  }
}
