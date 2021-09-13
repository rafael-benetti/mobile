import 'package:flutter/material.dart';
import '../models/counter_type.dart';
import '../services/api_service.dart';

import '../../locator.dart';

class CounterTypesProvider extends ChangeNotifier {
  List<CounterType> counterTypes = [];
  final _apiService = locator<ApiService>();

  Future<ApiResponse> getAllCounterTypes() async {
    return await _apiService.apiGet(route: ApiRoutes().counterTypes).then(
      (response) {
        if (response.status == Status.success) {
          counterTypes = List<CounterType>.from(
            response.data
                .map((counterType) => CounterType.fromJson(counterType))
                .toList(),
          );
          return response;
        } else {
          return response;
        }
      },
    );
  }

  Future<ApiResponse> editCounterType(
      Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPatch(route: ApiRoutes().counterTypes, body: data, params: '/$id')
        .then((response) {
      if (response.status == Status.success) {
        counterTypes[counterTypes.indexWhere((element) => element.id == id)] =
            CounterType.fromJson(response.data);
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }

  Future<ApiResponse> createCounterType(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().counterTypes, body: data)
        .then((response) {
      if (response.status == Status.success) {
        counterTypes.insert(0, CounterType.fromJson(response.data));
        notifyListeners();
        return response;
      } else {
        return response;
      }
    });
  }
}
