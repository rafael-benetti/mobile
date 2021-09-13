import '../../../src/core/models/counter_collection.dart';

class BoxCollection {
  String boxId;
  int prizeCount;
  List<CounterCollection> counterCollections = [];

  BoxCollection.fromMap(Map<String, dynamic> json) {
    boxId = json['boxId'];
    counterCollections = List<CounterCollection>.from(json['counterCollections']
        .map(
            (counterCollection) => CounterCollection.fromMap(counterCollection))
        .toList());
  }

  BoxCollection([String id]) {
    boxId = id;
  }

  Map<String, dynamic> toMap(bool editing) {
    var result = {
      'boxId': boxId,
      'prizeCount': prizeCount,
      'counterCollections': List.generate(
        counterCollections.length,
        (index) => counterCollections[index].toMap(editing),
      )
    };
    if (prizeCount == null) {
      result.remove('prizeCount');
    }
    return result;
  }
}
