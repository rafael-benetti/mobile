import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../src/core/models/detailed_operator_route.dart';
import '../models/route.dart';
import '../services/api_service.dart';
import '../../locator.dart';

class RoutesProvider extends ChangeNotifier {
  List<OperatorRoute> routes = [];
  List<OperatorRoute> filteredRoutes = [];
  int count = 0;
  DetailedOperatorRoute detailedRoute;
  final _apiService = locator<ApiService>();

  String _generateParams(int offset, String groupId, String operatorId,
      String pointOfSaleId, String label) {
    var params = '';
    if (offset == null) {
      return '';
    }
    params += '?offset=$offset';
    params += '&limit=5';
    if (groupId != null) {
      params += '&groupId=$groupId';
    }
    if (pointOfSaleId != null) {
      params += '&pointOfSaleId=$pointOfSaleId';
    }

    if (operatorId != null) {
      params += '&operatorId=$operatorId';
    }
    if (label != null) {
      params += '&label=$label';
    }
    return params;
  }

  void removeAtId(String id) {
    routes.removeWhere((element) => element.id == id);
    filterRoutes();
    notifyListeners();
  }

  void filterRoutes({String keywords}) {
    filteredRoutes = List<OperatorRoute>.from(routes);
    if (keywords != null) {
      filteredRoutes = filteredRoutes
          .where((element) => element.label.toLowerCase().contains(keywords))
          .toList();
    }
    notifyListeners();
  }

  Future<ApiResponse> getDetailedRoute(String routeId, String period) async {
    return await _apiService
        .apiGet(
            route: ApiRoutes().routes, queryParams: '/$routeId?period=$period')
        .then((response) {
      if (response.status == Status.success) {
        detailedRoute = DetailedOperatorRoute.fromMap(response.data);
      }
      notifyListeners();
      return response;
    });
  }

  Future<ApiResponse> getRoutes({
    int offset,
    String groupId,
    String operatorId,
    String pointOfSaleId,
    String label,
    bool shouldClearCurrentList,
  }) async {
    var params =
        _generateParams(offset, groupId, operatorId, pointOfSaleId, label);
    return await _apiService
        .apiGet(route: ApiRoutes().routesV2, queryParams: params)
        .then((response) {
      if (response.status == Status.success) {
        if (shouldClearCurrentList != null && shouldClearCurrentList) {
          routes = [];
        }
        routes += List<OperatorRoute>.from(response.data['routes']
            .map((route) => OperatorRoute.fromJson(route))
            .toList());
        count = 0;
        filterRoutes();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> deleteRoute(String id) async {
    return await _apiService
        .apiDelete(route: ApiRoutes().routes, params: '/$id')
        .then((response) {
      return response;
    });
  }

  Future<ApiResponse> editRoute(Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPut(route: ApiRoutes().routes, body: data, params: '/$id')
        .then((response) async {
      if (response.status == Status.success) {
        routes[routes.indexWhere((element) => element.id == id)] =
            OperatorRoute.fromJson(response.data);
        filterRoutes();
        await getDetailedRoute(
            OperatorRoute.fromJson(response.data).id, 'DAILY');
      }
      return response;
    });
  }

  Future<ApiResponse> createRoute(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().routes, body: data)
        .then((response) {
      if (response.status == Status.success) {
        routes.insert(0, OperatorRoute.fromJson(response.data));
        filterRoutes();
        return response;
      } else {
        return response;
      }
    });
  }
}
