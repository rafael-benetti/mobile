import 'permissions.dart';
import 'stock.dart';

enum Role { OWNER, MANAGER, OPERATOR }

class User {
  String id;
  String email;
  String name;
  String phoneNumber;
  Role role;
  String photo;
  Stock stock;
  Permissions permissions;
  List<String> groupIds;
  bool isActive;
  String deviceToken;

  User.manager() {
    isActive = true;
    groupIds = [];
    permissions = Permissions.forManager();
  }

  User.op() {
    isActive = true;
    groupIds = [];
    permissions = Permissions.forOperator();
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceToken = json['deviceToken'];
    email = json['email'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    isActive = json['isActive'];
    role = json['role'] == 'OWNER'
        ? Role.OWNER
        : json['role'] == 'MANAGER'
            ? Role.MANAGER
            : Role.OPERATOR;
    photo = json['photo'] != null ? json['photo']['downloadUrl'] : null;
    permissions = json['role'] == 'OWNER'
        ? Permissions.forOwner()
        : Permissions.fromJson(json['permissions'], json['role']);
    groupIds =
        json['groupIds'] == null ? null : List<String>.from(json['groupIds']);
    stock = json['stock'] != null ? Stock.fromJson(json['stock']) : null;
  }
}
