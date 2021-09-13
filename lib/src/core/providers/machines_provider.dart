import 'dart:convert';

import 'package:flutter/material.dart';

import '../../interface/shared/colors.dart';
import '../../interface/shared/validators.dart';
import '../../locator.dart';
import '../models/detailed_machine.dart';
import '../models/machine.dart';
import '../services/api_service.dart';
import '../services/interface_service.dart';

class MachinesProvider extends ChangeNotifier {
  final _apiService = locator<ApiService>();
  List<Machine> machines = [];
  List<Machine> filteredMachines = [];
  List<LeanMachine> leanMachines = [];
  int count;
  DetailedMachine detailedMachine;

  Future<ApiResponse> addRemoteCredit(
      Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPost(route: ApiRoutes().machineLogs, params: '/$id', body: data)
        .then((response) {
      return response;
    });
  }

  String _generateParams(
    String serialNumber,
    bool isActive,
    String telemetryStatus,
    String pointOfSaleId,
    String groupId,
    String routeId,
    String categoryId,
    int offset,
    bool noLimit,
    String operatorId,
  ) {
    var params = '';
    if (groupId != null) params += '?groupId=$groupId';

    if (categoryId != null) {
      if (params != '') {
        params += '&categoryId=$categoryId';
      } else {
        params += '?categoryId=$categoryId';
      }
    }
    if (routeId != null) {
      if (params != '') {
        params += '&routeId=$routeId';
      } else {
        params += '?routeId=$routeId';
      }
    }
    if (telemetryStatus != null) {
      if (params != '') {
        params +=
            '&telemetryStatus=${translateTelemetryStatus(telemetryStatus)}';
      } else {
        params +=
            '?telemetryStatus=${translateTelemetryStatus(telemetryStatus)}';
      }
    }
    if (pointOfSaleId != null) {
      if (params != '') {
        params += '&pointOfSaleId=$pointOfSaleId';
      } else {
        params += '?pointOfSaleId=$pointOfSaleId';
      }
    }
    if (serialNumber != null) {
      if (params != '') {
        params += '&serialNumber=$serialNumber';
      } else {
        params += '?serialNumber=$serialNumber';
      }
    }
    if (isActive != null) {
      if (params != '') {
        params += '&isActive=$isActive';
      } else {
        params += '?isActive=$isActive';
      }
    }
    if (offset != null) {
      if (params != '') {
        params += '&offset=$offset';
      } else {
        params += '?offset=$offset';
      }
    }
    if (operatorId != null) {
      if (params != '') {
        params += '&operatorId=$operatorId';
      } else {
        params += '?operatorId=$operatorId';
      }
    }

    if (noLimit == null) {
      params += '&limit=5';
    }
    return params;
  }

  Future<ApiResponse> getDetailedMachine(String id, String period) async {
    return await _apiService
        .apiGet(
            route: ApiRoutes().machines,
            queryParams: '/$id?period=${period.toString()}')
        .then(
      (response) {
        if (response.status == Status.success) {
          detailedMachine = DetailedMachine.fromJson(response.data);
        }
        notifyListeners();
        return response;
      },
    );
  }

  Future<ApiResponse> getLeanMachines() async {
    return await _apiService
        .apiGet(route: ApiRoutes().machines, queryParams: '?lean=true')
        .then(
      (response) {
        if (response.status == Status.success) {
          leanMachines = List<LeanMachine>.from(response.data['machines']
              .map((leanMachine) => LeanMachine.fromMap(leanMachine))
              .toList());
        }
        return response;
      },
    );
  }

  Future<ApiResponse> getAllMachines() async {
    return await _apiService
        .apiGet(
      route: ApiRoutes().machines,
    )
        .then((response) {
      if (response.status == Status.success) {
        machines = List<Machine>.from(response.data['machines']
            .map((machine) => Machine.fromMap(machine))
            .toList());
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> filterMachines({
    String serialNumber,
    bool isActive,
    String pointOfSaleId,
    String groupId,
    String routeId,
    String categoryId,
    String telemetryStatus,
    int offset,
    bool clearCurrentList,
    bool noLimit,
    String operatorId,
  }) async {
    return await _apiService
        .apiGet(
      route: ApiRoutes().machines,
      queryParams: _generateParams(
        serialNumber,
        isActive,
        telemetryStatus,
        pointOfSaleId,
        groupId,
        routeId,
        categoryId,
        offset,
        noLimit,
        operatorId,
      ),
    )
        .then((response) {
      if (response.status == Status.success) {
        if (clearCurrentList != null && clearCurrentList) {
          filteredMachines = [];
        }
        filteredMachines = filteredMachines +
            List<Machine>.from(response.data['machines']
                .map((machine) => Machine.fromMap(machine))
                .toList());
        count = response.data['count'];

        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> createMachine(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().machines, body: data)
        .then((response) {
      if (response.status == Status.success) {
        filteredMachines.insert(0, Machine.fromMap(response.data));
        count++;
        notifyListeners();
        return response;
      } else {
        locator<InterfaceService>().showSnackBar(
            message: json.encode(response.data),
            backgroundColor: locator<AppColors>().red);

        return response;
      }
    });
  }

  Future<ApiResponse> reloadMachineBox(
      String productId, Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(
            route: ApiRoutes().products,
            params: '/$productId/transfer',
            body: data)
        .then((response) {
      if (response.status == Status.success) {
        detailedMachine.boxesInfo
            .firstWhere((element) => element.boxId == data['to']['boxId'])
            .currentPrizeCount += data['productQuantity'];

        notifyListeners();
      }
      return response;
    });
  }

  Future<ApiResponse> deleteMachine(String id) async {
    return await _apiService.apiPut(
        route: ApiRoutes().machines,
        params: '/$id',
        body: {'isActive': false}).then((response) {
      if (response.status == Status.success) {
        filteredMachines.removeWhere((element) => element.id == id);
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> editMachine(Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPut(route: ApiRoutes().machines, params: '/$id', body: data)
        .then((response) async {
      if (response.status == Status.success) {
        try {
          filteredMachines[
                  filteredMachines.indexWhere((element) => element.id == id)] =
              Machine.fromMap(response.data);
          if (detailedMachine != null) {
            await getDetailedMachine(id, 'DAILY');
          }
        } catch (e) {
          print(e);
        }
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> removeFromMachine(
      Map<String, dynamic> data, String productId) async {
    return await _apiService
        .apiPatch(
            route: ApiRoutes().products,
            params: '/$productId/remove-from-machine',
            body: data)
        .then((response) {
      return response;
    });
  }

  Future<ApiResponse> fixMachineStock(
      Map<String, dynamic> data, String machineId) async {
    return await _apiService
        .apiPatch(
            route: ApiRoutes().machines,
            params: '/$machineId/fix-stock',
            body: data)
        .then(
      (response) {
        return response;
      },
    );
  }
}
