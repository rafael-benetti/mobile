import 'package:flutter/foundation.dart';
import '../../../src/core/models/detailed_machine.dart';
import '../../../src/core/services/api_service.dart';

import '../../locator.dart';

class MachineLogsProvider extends ChangeNotifier {
  final _apiService = locator<ApiService>();
  List<MachineLog> machineLogs = [];
  int count = 0;

  String _generateParams(int offset, String machineId, String startDate,
      String endDate, String type) {
    var params = '?machineId=$machineId&offset=$offset&limit=5';
    if (startDate != null) {
      params += '&startDate=$startDate';
    }
    if (endDate != null) {
      params += '&endDate=$endDate';
    }
    if (type != null) {
      params += '&type=$type';
    }
    return params;
  }

  Future<ApiResponse> getMachineLogs({
    @required int offset,
    @required String machineId,
    String startDate,
    String endDate,
    String type,
    bool shouldClearCurrentList,
  }) async {
    return await _apiService
        .apiGet(
            route: ApiRoutes().machineLogs,
            queryParams:
                _generateParams(offset, machineId, startDate, endDate, type))
        .then((response) {
      if (response.status == Status.success) {
        count = response.data['count'];
        if (shouldClearCurrentList != null && shouldClearCurrentList) {
          machineLogs = [];
        }
        machineLogs += List<MachineLog>.from(response.data['machineLogs']
            .map((machineLog) => MachineLog.fromMap(machineLog))
            .toList());
        notifyListeners();
      }
      return response;
    });
  }
}
