class PointOfSale {
  String id;
  String label;
  String contactName;
  String primaryPhoneNumber;
  String secondaryPhoneNumber;
  double rent;
  bool isPercentage;
  String zipCode;
  String city;
  String state;
  String street;
  String neighborhood;
  String number;
  String extraInfo;
  String groupId;
  String routeId;

  PointOfSale.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    contactName = json['contactName'];
    primaryPhoneNumber = json['primaryPhoneNumber'];
    secondaryPhoneNumber = json['secondaryPhoneNumber'];
    rent = double.parse(json['rent'].toString());
    isPercentage = json['isPercentage'];
    zipCode = json['address']['zipCode'];
    city = json['address']['city'];
    state = json['address']['state'];
    street = json['address']['street'];
    neighborhood = json['address']['neighborhood'];
    number = json['address']['number'];
    extraInfo = json['address']['extraInfo'];
    groupId = json['groupId'];
    routeId = json['routeId'];
  }
}
