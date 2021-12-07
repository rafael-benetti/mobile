import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

enum Status {
  error,
  success,
  timeout,
}

class ApiResponse {
  Status status;
  dynamic data;
  ApiResponse({
    this.status,
    this.data,
  });
}

class ApiRoutes {
  String operators = '/users/operators';
  String managers = '/users/managers';
  String auth = '/users/auth';
  String forgotPassword = '/users/forgot-password';
  String dashboard = '/users/dashboard';
  String dashboardV2 = '/v2/users/dashboard';
  String groups = '/groups';
  String groupsV2 = '/v2/groups';
  String profile = '/users/me';
  String machines = '/machines';
  String collections = '/collections';
  String categories = '/categories';
  String pointsOfSale = '/pointsOfSale';
  String products = '/products';
  String routes = '/routes';
  String routesV2 = '/v2/routes';
  String counterTypes = '/counterTypes';
  String telemetryBoards = '/telemetry-boards';
  String telemetryLogs = '/telemetry-logs';
  String notifications = '/notifications';
  String machineLogs = '/machine-logs';
}

class ApiService {
  static const String baseUrl = 'https://api.blacktelemetry.com';
  static Map<String, String> baseHeaders = {
    'content-type': 'application/json',
  };

  final _client = Client();
  final timeout = Duration(seconds: 80);

  Future<ApiResponse> apiGet({String route, String queryParams = ''}) async {
    try {
      return await _client
          .get(
            Uri.parse('$baseUrl$route$queryParams'),
            headers: baseHeaders,
          )
          .timeout(timeout)
          .then(
        (response) {
          if (response.statusCode == 200) {
            return ApiResponse(
              status: Status.success,
              data: json.decode(response.body),
            );
          } else {
            return ApiResponse(
              status: Status.error,
              data: response.body,
            );
          }
        },
      );
    } on TimeoutException {
      return ApiResponse(status: Status.error, data: null);
    } on SocketException {
      return ApiResponse(status: Status.error, data: null);
    } catch (e) {
      print('apiGet catch exception:' + e.toString());
      return ApiResponse(status: Status.error, data: null);
    }
  }

  Future<ApiResponse> apiPost(
      {String route, Map<String, dynamic> body, String params = ''}) async {
    try {
      return await _client
          .post(Uri.parse('$baseUrl$route$params'),
              headers: baseHeaders, body: json.encode(body))
          .timeout(timeout)
          .then(
        (response) {
          if (response.statusCode == 200 || response.statusCode == 201) {
            return ApiResponse(
              status: Status.success,
              data: json.decode(response.body),
            );
          } else if (response.statusCode == 204) {
            return ApiResponse(status: Status.success, data: {});
          } else {
            return ApiResponse(
              status: Status.error,
              data: response.body,
            );
          }
        },
      );
    } on TimeoutException {
      return ApiResponse(status: Status.error, data: null);
    } on SocketException {
      return ApiResponse(status: Status.error, data: null);
    } catch (e) {
      print('apiPost catch exception:' + e.toString());
      return ApiResponse(status: Status.error, data: null);
    }
  }

  Future<ApiResponse> apiDelete({String route, String params = ''}) async {
    try {
      return await _client
          .delete(Uri.parse('$baseUrl$route$params'), headers: baseHeaders)
          .timeout(timeout)
          .then((response) {
        if (response.statusCode == 200 || response.statusCode == 204) {
          return ApiResponse(data: null, status: Status.success);
        }
        return ApiResponse(
          data: json.decode(response.body),
          status: Status.error,
        );
      });
    } on TimeoutException {
      return ApiResponse(data: null, status: Status.timeout);
    } on SocketException {
      return ApiResponse(data: null, status: Status.error);
    } catch (e) {
      print('apiDelete catch exception:' + e.toString());
      return ApiResponse(data: null, status: Status.error);
    }
  }

  Future<ApiResponse> apiPatch(
      {Map<String, dynamic> body, String route, String params = ''}) async {
    try {
      return await _client
          .patch(
            Uri.parse('$baseUrl$route$params'),
            body: json.encode(body),
            headers: baseHeaders,
          )
          .timeout(timeout)
          .then((response) {
        if (response.statusCode == 200) {
          return ApiResponse(
            data: json.decode(response.body),
            status: Status.success,
          );
        } else if (response.statusCode == 204) {
          return ApiResponse(
            data: null,
            status: Status.success,
          );
        }
        return ApiResponse(
          data: json.decode(response.body),
          status: Status.error,
        );
      });
    } on TimeoutException {
      return ApiResponse(data: null, status: Status.timeout);
    } on SocketException {
      return ApiResponse(data: null, status: Status.error);
    } catch (e) {
      print('apiPatch catch exception:' + e.toString());
      return ApiResponse(data: null, status: Status.error);
    }
  }

  Future<ApiResponse> apiPut(
      {Map<String, dynamic> body, String route, String params = ''}) async {
    try {
      return await _client
          .put(
            Uri.parse('$baseUrl$route$params'),
            body: body != null ? json.encode(body) : json.encode({}),
            headers: baseHeaders,
          )
          .timeout(timeout)
          .then((response) {
        if (response.statusCode == 200) {
          return ApiResponse(
            data: json.decode(response.body),
            status: Status.success,
          );
        }
        if (response.statusCode == 204) {
          return ApiResponse(
            data: null,
            status: Status.success,
          );
        }
        return ApiResponse(
          data: json.decode(response.body),
          status: Status.error,
        );
      });
    } on TimeoutException {
      return ApiResponse(data: null, status: Status.timeout);
    } on SocketException {
      return ApiResponse(data: null, status: Status.error);
    } catch (e) {
      print('apiPut catch exception:' + e.toString());
      return ApiResponse(data: null, status: Status.error);
    }
  }

  Future<void> generateToken(String token) async {
    baseHeaders = {
      'content-type': 'application/json',
      'authorization': 'Bearer $token'
    };
  }
}
