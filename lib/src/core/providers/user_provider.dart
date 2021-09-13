import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../locator.dart';
import '../models/prize.dart';
import '../models/supply.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';

class UserProvider extends ChangeNotifier {
  User _user;
  List<Prize> prizes = [];
  List<Supply> supplies = [];
  List<User> operators = [];
  List<User> managers = [];
  List<User> filteredManagers = [];
  List<User> filteredOperators = [];
  final _apiService = locator<ApiService>();
  final _hiveService = locator<HiveService>();
  User get user => _user;

  Future<List<User>> getAvailableOperators(List<String> groupIds) async {
    await getAllOperators();
    if (groupIds != null && groupIds.isNotEmpty) {
      var temp = <User>[];
      var groupIdsSet = groupIds.toSet();
      operators.forEach((op) {
        var opSet = op.groupIds.toSet();
        if (setEquals(opSet.intersection(groupIdsSet), groupIdsSet)) {
          temp.add(op);
        }
      });
      return temp;
    } else {
      return operators;
    }
  }

  void setUser(value) {
    _user = value;
  }

  void setStock() {
    if (_user.stock != null) {
      prizes = _user.stock.prizes;
      supplies = _user.stock.supplies;
    }
  }

  Future<ApiResponse> authenticate(String email, String pass) async {
    return await _apiService.apiPost(
        route: ApiRoutes().auth, body: {'email': email, 'password': pass}).then(
      (response) {
        if (response.status == Status.success) {
          _apiService.generateToken(response.data['token']);
          setUser(User.fromJson(response.data['user']));
          setStock();
          _hiveService.clearBox('JWT');
          _hiveService.addToBox(response.data['token'], 'JWT');
          return response;
        } else {
          return response;
        }
      },
    );
  }

  Future<ApiResponse> forgotPassword(String email) async {
    return await _apiService.apiPost(
        route: ApiRoutes().forgotPassword, body: {'email': email}).then(
      (response) {
        return response;
      },
    );
  }

  void filterOperators({String keywords}) {
    filteredOperators = List<User>.from(operators);
    if (keywords != null) {
      filteredOperators = filteredOperators
          .where((element) =>
              element.name.toLowerCase().contains(keywords.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterManagers({String keywords}) {
    filteredManagers = List<User>.from(managers);
    if (keywords != null) {
      filteredManagers = filteredManagers
          .where((element) =>
              element.name.toLowerCase().contains(keywords.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<ApiResponse> editManager(Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPatch(route: ApiRoutes().managers, body: data, params: '/$id')
        .then((response) {
      if (response.status == Status.success) {
        managers[managers.indexWhere((element) => element.id == id)] =
            User.fromJson(response.data);
        filterManagers();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> createManager(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().managers, body: data)
        .then((response) {
      if (response.status == Status.success) {
        managers.insert(0, User.fromJson(response.data));
        filterManagers();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> getAllManagers() async {
    return await _apiService.apiGet(route: ApiRoutes().managers).then(
      (response) {
        if (response.status == Status.success) {
          managers = List<User>.from(
              response.data.map((user) => User.fromJson(user)).toList());
          filterManagers();
          return response;
        } else {
          return response;
        }
      },
    );
  }

  Future<ApiResponse> editOperator(Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPatch(route: ApiRoutes().operators, body: data, params: '/$id')
        .then((response) {
      if (response.status == Status.success) {
        operators[operators.indexWhere((element) => element.id == id)] =
            User.fromJson(response.data);
        filterOperators();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> createOperator(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().operators, body: data)
        .then((response) {
      if (response.status == Status.success) {
        operators.insert(0, User.fromJson(response.data));
        filterOperators();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> getAllOperators() async {
    return await _apiService.apiGet(route: ApiRoutes().operators).then(
      (response) {
        if (response.status == Status.success) {
          operators = List<User>.from(
              response.data.map((user) => User.fromJson(user)).toList());
          filterOperators();
          return response;
        } else {
          return response;
        }
      },
    );
  }

  Future<ApiResponse> fetchUser() async {
    return await _apiService
        .apiGet(route: ApiRoutes().profile)
        .then((response) {
      if (response.status == Status.success) {
        setUser(User.fromJson(response.data));
        setStock();
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> transferFromUserStock(
      Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPost(
            route: ApiRoutes().products, params: '/$id/transfer', body: data)
        .then((response) async {
      if (response.status == Status.success) {
        await fetchUser();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> updateDeviceToken(String deviceToken) async {
    return await _apiService.apiPatch(
        route: ApiRoutes().profile, body: {'deviceToken': deviceToken}).then(
      (response) {
        if (response.status == Status.success) {
          user.deviceToken = deviceToken;
        }
        return response;
      },
    );
  }
}
