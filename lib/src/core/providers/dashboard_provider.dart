import 'package:flutter/foundation.dart';
import '../../../src/core/models/dashboard.dart';
import '../../../src/core/models/notification.dart';
import '../../../src/core/services/api_service.dart';

import '../../locator.dart';

class DashboardProvider extends ChangeNotifier {
  Dashboard dashboard;
  List<Notification> notifications = [];
  int numberOfUnreadNotifications = 0;
  int notificationsCount = 0;
  final _apiService = locator<ApiService>();

  Future getNumberOfNotifications() async {
    return await _apiService
        .apiGet(route: ApiRoutes().notifications, queryParams: '/count')
        .then((response) {
      if (response.status == Status.success) {
        numberOfUnreadNotifications =
            response.data['numberOfUnreadNotifications'];
        notifyListeners();
      }
    });
  }

  Future<ApiResponse> getNotifications({int offset}) async {
    return await _apiService
        .apiGet(
            route: ApiRoutes().notifications,
            queryParams: '?limit=5&offset=$offset')
        .then((response) {
      if (response.status == Status.success) {
        notifications = notifications +
            List<Notification>.from(response.data['notifications']
                .map((notification) => Notification.fromMap(notification))
                .toList());
        notificationsCount = response.data['count'];
      }
      notifyListeners();
      return response;
    });
  }

  String _generateParams(
      String period, String groupId, String routeId, String pointOfSaleId) {
    var params = '?period=$period';
    if (groupId != null) {
      params += '&groupId=$groupId';
    }
    if (routeId != null) {
      params += '&routeId=$routeId';
    }
    if (pointOfSaleId != null) {
      params += '&pointOfSaleId=$pointOfSaleId';
    }
    return params;
  }

  Future<ApiResponse> fetchData(String period, String groupId, String routeId,
      String pointOfSaleId) async {
    var params = _generateParams(period, groupId, routeId, pointOfSaleId);
    return await _apiService
        .apiGet(route: ApiRoutes().dashboardV2, queryParams: params)
        .then((response) async {
      if (response.status == Status.success) {
        dashboard = Dashboard.fromMap(response.data);
        notifyListeners();
      }
      return response;
    });
  }
}
