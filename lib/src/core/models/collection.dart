import 'box_collection.dart';
import 'machine.dart';

class Coordinates {
  double latitude;
  double longitude;

  Coordinates.fromMap(Map<String, dynamic> json) {
    latitude = json['latitude'].toDouble();
    longitude = json['longitude'].toDouble();
  }
}

class ReviewedData {
  DateTime date;
  String reviewedBy;
  String reviewerName;

  ReviewedData();

  ReviewedData.fromMap(Map<String, dynamic> json) {
    date = DateTime.parse(json['date']);
    reviewedBy = json['reviewedBy'];
    reviewerName = json['reviewerName'];
  }
}

class Collection {
  String id;
  Collection previousCollection;
  String machineId;
  Machine machine;
  String userName;
  String pointOfSaleLabel;
  String observations;
  DateTime endTime;
  DateTime startTime;
  Coordinates startLocation;
  Coordinates endLocation;
  ReviewedData reviewedData;

  List<BoxCollection> boxCollections = [];

  Collection();

  Collection.previous(Map<String, dynamic> previous) {
    userName = previous['user'] != null ? previous['user']['name'] : null;
    endTime = DateTime.parse(previous['date']);
    startTime = previous['startTime'] != null
        ? DateTime.parse(previous['startTime'])
        : null;
    boxCollections = List<BoxCollection>.from(
      previous['boxCollections']
          .map((boxCollection) => BoxCollection.fromMap(boxCollection))
          .toList(),
    );
  }

  Collection.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    previousCollection = json['previousCollection'] != null
        ? Collection.previous(json['previousCollection'])
        : null;
    machineId = json['machineId'];
    reviewedData = json['reviewedData'] != null
        ? ReviewedData.fromMap(json['reviewedData'])
        : null;
    machine = json['machine'] != null ? Machine.fromMap(json['machine']) : null;
    userName = json['user']['name'];
    pointOfSaleLabel = json['pointOfSale']['label'];
    observations = json['observations'];
    startLocation = json['startLocation'] != null
        ? Coordinates.fromMap(json['startLocation'])
        : null;
    endLocation = json['endLocation'] != null
        ? Coordinates.fromMap(json['endLocation'])
        : null;
    startTime =
        json['startTime'] != null ? DateTime.parse(json['startTime']) : null;
    endTime = DateTime.parse(json['date']);
    boxCollections = List<BoxCollection>.from(json['boxCollections']
        .map((boxCollection) => BoxCollection.fromMap(boxCollection))
        .toList());
  }

  Map<String, dynamic> toMap(bool editing) {
    return {
      'machineId': machineId,
      'observations': observations,
      'boxCollections': List.generate(
        boxCollections.length,
        (index) => boxCollections[index].toMap(editing),
      )
    };
  }
}
