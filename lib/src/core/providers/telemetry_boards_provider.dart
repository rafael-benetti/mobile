import 'package:flutter/foundation.dart';
import '../models/telemetry_board.dart';
import '../services/api_service.dart';

import '../../locator.dart';

class TelemetryBoardsProvider extends ChangeNotifier {
  List<TelemetryBoard> telemetries = [];
  final _apiService = locator<ApiService>();
  int count = 0;

  Future<ApiResponse> transferBoard(Map<String, dynamic> data, int id) async {
    return await _apiService
        .apiPatch(
            route: ApiRoutes().telemetryBoards, params: '/$id', body: data)
        .then((response) {
      if (response.status == Status.success) {
        telemetries[telemetries.indexWhere((element) => element.id == id)]
            .groupId = data['groupId'];
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  String generateParams(int offset, String groupId, String telemetryBoardId) {
    var tmp = '';
    if (offset != null) {
      tmp += '?offset=$offset';
    }
    if (groupId != null) {
      if (tmp == '') {
        tmp += '?groupId=$groupId';
      } else {
        tmp += '&groupId=$groupId';
      }
    }
    if (telemetryBoardId != null) {
      if (tmp == '') {
        tmp += '?telemetryBoardId=$telemetryBoardId';
      } else {
        tmp += '&telemetryBoardId=$telemetryBoardId';
      }
    }
    if (tmp == '') {
      tmp += '?limit=5';
    } else {
      tmp += '&limit=5';
    }
    return tmp;
  }

  Future<ApiResponse> getFilteredTelemetries({
    int offset,
    String groupId,
    String telemetryBoardId,
    bool shouldClearCurrentList,
  }) async {
    return await _apiService
        .apiGet(
      route: ApiRoutes().telemetryBoards,
      queryParams: generateParams(offset, groupId, telemetryBoardId),
    )
        .then((response) {
      if (response.status == Status.success) {
        if (shouldClearCurrentList != null && shouldClearCurrentList) {
          telemetries = [];
        }
        telemetries += List<TelemetryBoard>.from(response
            .data['telemetryBoards']
            .map((tBoard) => TelemetryBoard.fromJson(tBoard))
            .toList());
        count = response.data['count'];
        notifyListeners();
      }
      return response;
    });
  }

  Future<ApiResponse> getAllTelemetries() async {
    return await _apiService
        .apiGet(route: ApiRoutes().telemetryBoards)
        .then((response) {
      telemetries = [];
      telemetries = List<TelemetryBoard>.from(response.data['telemetryBoards']
          .map((tBoard) => TelemetryBoard.fromJson(tBoard))
          .toList());
      notifyListeners();
      return response;
    });
  }
}
