import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../src/interface/shared/error_translator.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/interface_service.dart';
import '../../interface/shared/colors.dart';

import '../../locator.dart';

class CategoriesProvider extends ChangeNotifier {
  List<Category> categories = [];
  List<Category> filteredCategories = [];
  final _apiService = locator<ApiService>();

  void filterCategories([String keywords]) {
    filteredCategories = categories;
    if (keywords != null && keywords != '') {
      filteredCategories = categories
          .where((element) => element.label.toLowerCase().contains(keywords))
          .toList();
    }
    notifyListeners();
  }

  Future<ApiResponse> getAllCategories() async {
    return await _apiService.apiGet(route: ApiRoutes().categories).then(
      (response) {
        if (response.status == Status.success) {
          categories = List<Category>.from(response.data
              .map((category) => Category.fromJson(category))
              .toList());
          filterCategories();
          return response;
        } else {
          return response;
        }
      },
    );
  }

  Future<ApiResponse> createCategory(Map<String, dynamic> data) async {
    return await _apiService
        .apiPost(route: ApiRoutes().categories, body: data)
        .then((response) {
      if (response.status == Status.success) {
        categories.insert(0, Category.fromJson(response.data));
        filterCategories();
        return response;
      } else {
        locator<InterfaceService>().showSnackBar(
            message: json.encode(response.data),
            backgroundColor: locator<AppColors>().red);
        return response;
      }
    });
  }

  Future<ApiResponse> editCategory(Map<String, dynamic> data, String id) async {
    return await _apiService
        .apiPut(route: ApiRoutes().categories, body: data, params: '/$id')
        .then((response) {
      if (response.status == Status.success) {
        categories[categories.indexWhere((element) => element.id == id)] =
            Category.fromJson(response.data);
        filterCategories();
        return response;
      } else {
        locator<InterfaceService>().showSnackBar(
            message: translateError(response.data),
            backgroundColor: locator<AppColors>().red);
        return response;
      }
    });
  }
}
