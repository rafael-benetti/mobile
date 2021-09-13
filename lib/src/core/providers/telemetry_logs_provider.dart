import 'package:flutter/foundation.dart';
import '../../../src/core/models/detailed_machine.dart';
import '../../../src/core/services/api_service.dart';

import '../../locator.dart';

class TelemetryLogsProvider extends ChangeNotifier {
  final _apiService = locator<ApiService>();
  List<TelemetryLog> telemetryLogs = [];
  int count = 0;

  String _generateParams(int offset, String machineId, String startDate,
      String endDate, String type) {
    var params = '?machineId=$machineId&offset=$offset&limit=6';
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

  Future<ApiResponse> getTelemetryLogs({
    @required int offset,
    @required String machineId,
    String startDate,
    String endDate,
    String type,
    bool shouldClearCurrentList,
  }) async {
    return await _apiService
        .apiGet(
            route: ApiRoutes().telemetryLogs,
            queryParams:
                _generateParams(offset, machineId, startDate, endDate, type))
        .then((response) {
      if (response.status == Status.success) {
        count = response.data['count'];
        if (shouldClearCurrentList != null && shouldClearCurrentList) {
          telemetryLogs = [];
        }
        telemetryLogs += List<TelemetryLog>.from(response.data['telemetryLogs']
            .map((telemetryLog) => TelemetryLog.fromMap(telemetryLog))
            .toList());
        notifyListeners();
      }
      return response;
    });
  }
}
