import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/providers/points_of_sale_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/interface_service.dart';
import '../../../locator.dart';
import '../../shared/colors.dart';

class ReportsPageModel extends BaseViewModel {
  final interfaceService = locator<InterfaceService>();
  final colors = locator<AppColors>();
  final pointsOfSaleProvider = locator<PointsOfSaleProvider>();

  String savePath;
  String selectedReportType;
  DateTimeRange dateRange;
  String selectedPointOfSaleId;
  void onSelect(String type) async {
    selectedReportType = type;
    if (type == 'collections') {
      if (pointsOfSaleProvider.pointsOfSale.isEmpty) {
        setBusy(true);
        await pointsOfSaleProvider.getAllPointsOfSale();
        setBusy(false);
      }
    }
    notifyListeners();
  }

  void showDateRangePicker() {
    interfaceService.showModal(
      widget: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              locator<InterfaceService>().goBack();
              notifyListeners();
            },
            icon: Icon(
              Icons.keyboard_arrow_down_outlined,
              color: Colors.black,
              size: 25,
            ),
          ),
          title: Text('Selecione o período'),
          iconTheme: IconThemeData(color: colors.primaryColor),
        ),
        backgroundColor: colors.backgroundColor,
        body: SfDateRangePicker(
          maxDate: DateTime.now(),
          minDate: DateTime(DateTime.now().year - 5),
          rangeSelectionColor: colors.primaryColor.withOpacity(0.5),
          endRangeSelectionColor: colors.primaryColor,
          startRangeSelectionColor: colors.primaryColor,
          onSelectionChanged: (args) {
            if (args.value is PickerDateRange) {
              PickerDateRange pickerDateRange = args.value;
              if (pickerDateRange.startDate != null &&
                  pickerDateRange.endDate != null) {
                dateRange = DateTimeRange(
                  start: pickerDateRange.startDate,
                  end: pickerDateRange.endDate,
                );
              }
            }
          },
          selectionMode: DateRangePickerSelectionMode.range,
          initialSelectedRange: dateRange != null
              ? PickerDateRange(
                  dateRange.start,
                  dateRange.end,
                )
              : null,
        ),
      ),
    );
  }

  void baga() async {
    if (savePath == null) {
      await findLocalPath();
    }
    interfaceService.showLoader();
    switch (selectedReportType) {
      case 'stocks':
        var response = await apiGet(
            baseUrl: ApiService.baseUrl,
            route: '/reports/stocks',
            queryParams: '?download=true');
        if (response.status == Status.success) {
          var file = File(savePath);
          await file.writeAsBytes(response.data);
          interfaceService.closeLoader();
          await OpenFile.open(savePath);
        }
        return;
      case 'groups':
        var response = await apiGet(
            baseUrl: ApiService.baseUrl,
            route: '/reports/groups',
            queryParams:
                '?download=true&startDate=${dateRange.start.toIso8601String()}&endDate=${dateRange.end.toIso8601String()}');
        if (response.status == Status.success) {
          var file = File(savePath);
          await file.writeAsBytes(response.data);
          interfaceService.closeLoader();
          await OpenFile.open(savePath);
        }
        return;
      case 'machines':
        var response = await apiGet(
            baseUrl: ApiService.baseUrl,
            route: '/reports/machines',
            queryParams:
                '?download=true&startDate=${dateRange.start.toIso8601String()}&endDate=${dateRange.end.toIso8601String()}');
        if (response.status == Status.success) {
          var file = File(savePath);
          await file.writeAsBytes(response.data);
          interfaceService.closeLoader();
          await OpenFile.open(savePath);
        }
        return;
      case 'collections':
        var response = await apiGet(
            baseUrl: ApiService.baseUrl,
            route: '/reports/collections',
            queryParams:
                '?download=true&startDate=${dateRange.start.toIso8601String()}&endDate=${dateRange.end.toIso8601String()}&pointOfSaleId=$selectedPointOfSaleId');
        if (response.status == Status.success) {
          var file = File(savePath);
          await file.writeAsBytes(response.data);
          interfaceService.closeLoader();
          await OpenFile.open(savePath);
        }
        return;
      case 'pointsOfSale':
        var response = await apiGet(
            baseUrl: ApiService.baseUrl,
            route: '/reports/points-of-sale',
            queryParams:
                '?download=true&startDate=${dateRange.start.toIso8601String()}&endDate=${dateRange.end.toIso8601String()}');
        if (response.status == Status.success) {
          var file = File(savePath);
          await file.writeAsBytes(response.data);
          interfaceService.closeLoader();
          await OpenFile.open(savePath);
        }
        return;
      default:
    }
  }

  Future<ApiResponse> apiGet(
      {String baseUrl, String route, String queryParams = ''}) async {
    var response = ApiResponse(data: null, status: Status.error);
    var request = await Dio().get(
      '$baseUrl$route$queryParams',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'content-type':
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'authorization': ApiService.baseHeaders['authorization'],
        },
      ),
    );
    if (request.statusCode == 200) {
      response = ApiResponse(data: request.data, status: Status.success);
    }
    return response;
  }

  Future findLocalPath() async {
    var appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    var appDocumentsPath = appDocumentsDirectory.path; // 2
    var filePath =
        '$appDocumentsPath/relatório-${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}.xlsx'; // 3

    savePath = filePath;
  }
}
