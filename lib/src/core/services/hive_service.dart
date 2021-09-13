import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  Future initHive() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    return Hive.openBox('JWT');
  }

  Future boxNotEmpty({String boxName}) async {
    final openBox = await Hive.openBox(boxName);
    var length = openBox.length;
    return length != 0;
  }

  Future addToBox<T>(var item, String boxName) async {
    final openBox = await Hive.openBox(boxName);
    await openBox.add(item);
  }

  Future clearBox(String boxName) async {
    await Hive.box(boxName).clear();
  }

  Future getDataFromBox<T>(String boxName) async {
    var boxList = <T>[];
    final openBox = await Hive.openBox(boxName);
    var length = openBox.length;
    for (var i = 0; i < length; i++) {
      boxList.add(openBox.getAt(i));
    }
    return boxList[0];
  }
}
