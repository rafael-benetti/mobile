import 'package:flutter/material.dart';
import '../../../src/core/models/detailed_group.dart';
import '../models/group.dart';
import '../models/machine.dart';
import '../models/prize.dart';
import '../models/supply.dart';
import '../services/api_service.dart';

import '../../locator.dart';
import 'machines_provider.dart';

class GroupsProvider extends ChangeNotifier {
  //GROUP RELATED
  DetailedGroup detailedGroup;
  List<Group> groups = [];
  List<Group> filteredGroups = [];
  final _apiService = locator<ApiService>();
  final _machinesProvider = locator<MachinesProvider>();

  void filterGroups({String value}) {
    filteredGroups = groups;
    if (value != null && value != '') {
      filteredGroups = groups
          .where((element) => element.label.toLowerCase().contains(value))
          .toList();
    }
    notifyListeners();
  }

  Future<ApiResponse> getDetailedGroup(String id, String period) async {
    return await _apiService
        .apiGet(route: ApiRoutes().groupsV2, queryParams: '/$id?period=$period')
        .then((response) {
      if (response.status == Status.success) {
        detailedGroup = DetailedGroup.fromMap(response.data);
        notifyListeners();
      }
      return response;
    });
  }

  Future<ApiResponse> createGroup(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().groups, body: data)
        .then((response) {
      if (response.status == Status.success) {
        groups = List<Group>.from(groups)
          ..insert(0, Group.fromMap(response.data));
        filterGroups();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> editGroup(String id, Map<String, dynamic> data) async {
    return await _apiService
        .apiPatch(route: ApiRoutes().groups, params: '/$id', body: data)
        .then((response) {
      if (response.status == Status.success) {
        groups[groups.indexWhere((element) => element.id == id)] =
            Group.fromMap(response.data);
        detailedGroup.group = Group.fromMap(response.data);
        filterGroups();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> getAllGroups() async {
    return await _apiService.apiGet(route: ApiRoutes().groups).then((response) {
      if (response.status == Status.success) {
        groups = List<Group>.from(
            response.data.map((group) => Group.fromMap(group)).toList());
        filterGroups();
        return response;
      } else {
        return response;
      }
    });
  }

  //STOCK RELATED
  List<Prize> prizes = [];
  List<Machine> machinesInStock = [];
  List<Supply> supplies = [];

  void getGroupPrizesByGroupId(String groupId) {
    prizes = [];
    prizes += groups.firstWhere((group) => group.id == groupId).stock.prizes;
    notifyListeners();
  }

  Future getStock({String groupId}) async {
    prizes = [];
    supplies = [];
    machinesInStock = [];
    if (groupId == null) {
      groups.forEach(
        (group) {
          prizes += group.stock.prizes;
          supplies += group.stock.supplies;
        },
      );
      await _machinesProvider.filterMachines(
        pointOfSaleId: 'null',
        clearCurrentList: true,
        noLimit: true,
      );
      machinesInStock = _machinesProvider.filteredMachines;
    } else {
      prizes += groups.firstWhere((group) => group.id == groupId).stock.prizes;
      supplies +=
          groups.firstWhere((group) => group.id == groupId).stock.supplies;
      await _machinesProvider.filterMachines(
        pointOfSaleId: 'null',
        groupId: groupId,
        clearCurrentList: true,
        noLimit: true,
      );
      machinesInStock = List<Machine>.from(_machinesProvider.filteredMachines);
    }
    notifyListeners();
  }

  Future<ApiResponse> createSupply(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().products, body: data)
        .then((response) {
      if (response.status == Status.success) {
        supplies.insert(0, Supply.fromJson(response.data, data['groupId']));
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> createPrize(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().products, body: data)
        .then((response) {
      if (response.status == Status.success) {
        prizes.insert(0, Prize.fromMap(response.data, data['groupId']));
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> addToStock(Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPost(
            route: ApiRoutes().products,
            body: data,
            params: '/$id/add-to-stock')
        .then((response) async {
      if (response.status == Status.success) {
        await getAllGroups();
        await getStock();
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> transferFromGroupStock(
      Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPost(
            route: ApiRoutes().products, params: '/$id/transfer', body: data)
        .then((response) async {
      if (response.status == Status.success) {
        await getAllGroups();
        await getStock();
        return response;
      } else {
        return response;
      }
    });
  }
}
