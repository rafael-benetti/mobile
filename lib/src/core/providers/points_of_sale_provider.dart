import 'package:flutter/material.dart';
import '../../../src/core/models/detailed_point_of_sale.dart';
import '../models/point_of_sale.dart';
import '../services/api_service.dart';
import '../../locator.dart';

class PointsOfSaleProvider extends ChangeNotifier {
  List<PointOfSale> pointsOfSale = [];
  final _apiService = locator<ApiService>();
  List<PointOfSale> filteredPointsOfSale = [];
  List<PointOfSale> routelessPointsOfSale = [];
  int count = 0;
  DetailedPointOfSale detailedPointOfSale;

  void getRoutelessPointsOfSale() {
    routelessPointsOfSale =
        pointsOfSale.where((element) => element.routeId == null).toList();
    notifyListeners();
  }

  Future<ApiResponse> getDetailedPointsOfSale(String id, String period) async {
    return await _apiService
        .apiGet(
            route: ApiRoutes().pointsOfSale, queryParams: '/$id?period=$period')
        .then(
      (response) {
        if (response.status == Status.success) {
          detailedPointOfSale = DetailedPointOfSale.fromJson(response.data);
        }
        notifyListeners();
        return response;
      },
    );
  }

  Future<ApiResponse> createPointOfSale(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().pointsOfSale, body: data)
        .then((response) {
      if (response.status == Status.success) {
        pointsOfSale.add(PointOfSale.fromMap(response.data));
        filteredPointsOfSale.insert(0, PointOfSale.fromMap(response.data));
        count++;
        notifyListeners();

        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> editPointOfSale(
      String id, Map<String, dynamic> data) async {
    return await _apiService
        .apiPatch(route: ApiRoutes().pointsOfSale, body: data, params: '/$id')
        .then(
      (response) {
        if (response.status == Status.success) {
          filteredPointsOfSale[filteredPointsOfSale
                  .indexWhere((element) => element.id == id)] =
              PointOfSale.fromMap(response.data);
          pointsOfSale[pointsOfSale.indexWhere((element) => element.id == id)] =
              PointOfSale.fromMap(response.data);
          notifyListeners();
          return response;
        } else {
          return response;
        }
      },
    );
  }

  String _generateParams(String label, String groupId, int offset,
      String routeId, String operatorId, bool limitless) {
    var params = '';
    if (groupId != null) params += '?groupId=$groupId';

    if (label != null) {
      if (params != '') {
        params += '&label=$label';
      } else {
        params += '?label=$label';
      }
    }
    if (offset != null) {
      if (params != '') {
        params += '&offset=$offset';
      } else {
        params += '?offset=$offset';
      }
    }
    if (routeId != null) {
      if (params != '') {
        params += '&routeId=$routeId';
      } else {
        params += '?routeId=$routeId';
      }
    }
    if (operatorId != null) {
      if (params != '') {
        params += '&operatorId=$operatorId';
      } else {
        params += '?operatorId=$operatorId';
      }
    }
    if (limitless == null || !limitless) {
      if (params != '') {
        params += '&limit=5';
      } else {
        params = '?limit=5';
      }
    }
    return params;
  }

  Future<ApiResponse> filterPointsOfSale(
      {String label,
      String groupId,
      int offset,
      bool clearCurrentList,
      String routeId,
      String operatorId,
      bool limitless}) async {
    print(
      _generateParams(label, groupId, offset, routeId, operatorId, limitless),
    );
    return await _apiService
        .apiGet(
      route: ApiRoutes().pointsOfSale,
      queryParams: _generateParams(
          label, groupId, offset, routeId, operatorId, limitless),
    )
        .then((response) {
      if (response.status == Status.success) {
        if (clearCurrentList != null && clearCurrentList) {
          filteredPointsOfSale = [];
        }
        filteredPointsOfSale = filteredPointsOfSale +
            List<PointOfSale>.from(response.data['pointsOfSale']
                .map((machine) => PointOfSale.fromMap(machine))
                .toList());

        count = response.data['count'];
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> getAllPointsOfSale() async {
    return await _apiService
        .apiGet(route: ApiRoutes().pointsOfSale)
        .then((response) {
      if (response.status == Status.success) {
        pointsOfSale = List<PointOfSale>.from(response.data['pointsOfSale']
            .map((point) => PointOfSale.fromMap(point))
            .toList());
        getRoutelessPointsOfSale();
        return response;
      } else {
        return response;
      }
    });
  }
}
