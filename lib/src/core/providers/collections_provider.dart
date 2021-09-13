import 'package:flutter/foundation.dart';
import '../../../src/core/models/collection.dart';
import '../../../src/core/services/api_service.dart';

import '../../locator.dart';

class CollectionsProvider extends ChangeNotifier {
  List<Collection> collections = [];
  List<Collection> filteredCollections = [];
  Collection detailedCollection;
  final _apiService = locator<ApiService>();
  int count = 0;

  void addToFilteredCollections(Map<String, dynamic> response) {
    filteredCollections.insert(0, Collection.fromMap(response));
    notifyListeners();
    count++;
  }

  void setDetailedCollection(Collection collection) {
    detailedCollection = collection;
  }

  void updateDetailedCollection(Collection collection) {
    detailedCollection = collection;
    notifyListeners();
  }

  String _generateParams(
      int offset, String keywords, String routeId, String operatorId) {
    var params = '';
    if (keywords != null) params += '?machineSerialNumber=$keywords';

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
    params += '&limit=5';
    return params;
  }

  Future<ApiResponse> reviewCollection(String id) async {
    return await _apiService
        .apiPut(route: ApiRoutes().collections, params: '/review/$id')
        .then((response) {
      if (response.status == Status.success) {
        detailedCollection.reviewedData = ReviewedData.fromMap(response.data);
        notifyListeners();
      }
      return response;
    });
  }

  Future<ApiResponse> getCollections({
    int offset,
    String keywords,
    bool clearCurrentList,
    String routeId,
    String operatorId,
  }) async {
    return await _apiService
        .apiGet(
      route: ApiRoutes().collections,
      queryParams: _generateParams(offset, keywords, routeId, operatorId),
    )
        .then(
      (response) {
        if (response.status == Status.success) {
          if (clearCurrentList != null && clearCurrentList) {
            filteredCollections = [];
          }
          filteredCollections += List<Collection>.from(response
              .data['collections']
              .map((collection) => Collection.fromMap(collection))
              .toList());
          count = response.data['count'];
          notifyListeners();
        }
        return response;
      },
    );
  }
}
