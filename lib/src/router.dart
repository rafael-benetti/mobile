import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'interface/pages/collections/collections_page.dart';
import 'interface/pages/detailed_collection/detailed_collection_page.dart';
import 'interface/pages/detailed_group/detailed_group_page.dart';
import 'interface/pages/detailed_machine/detailed_machine_page.dart';
import 'interface/pages/detailed_operator/detailed_operator_page.dart';
import 'interface/pages/detailed_route/detailed_route_page.dart';
import 'interface/pages/edit_collection/edit_collection_page.dart';
import 'interface/pages/machine_logs/machine_logs_page.dart';
import 'interface/pages/photo_view/full_photo_page.dart';
import 'interface/pages/edit_group/edit_group_page.dart';
import 'interface/pages/managers/managers_page.dart';
import 'interface/pages/categories/categories_page.dart';
import 'interface/pages/counter_types/counter_types_page.dart';
import 'interface/pages/detailed_point_of_sale/detailed_point_of_sale_page.dart';
import 'interface/pages/edit_category/edit_category_page.dart';
import 'interface/pages/edit_counter_type/edit_counter_type_page.dart';
import 'interface/pages/edit_machine/edit_machine_page.dart';
import 'interface/pages/edit_manager/edit_manager_page.dart';
import 'interface/pages/edit_operator/edit_operator_page.dart';
import 'interface/pages/edit_profile/edit_profile_page.dart';
import 'interface/pages/edit_point_of_sale/edit_point_of_sale_page.dart';
import 'interface/pages/edit_route/edit_route_page.dart';
import 'interface/pages/group_stock/group_stock_page.dart';
import 'interface/pages/groups/groups_page.dart';
import 'interface/pages/home/home_page.dart';
import 'interface/pages/login/login_page.dart';
import 'interface/pages/machines/machines_page.dart';
import 'interface/pages/operators/operators_page.dart';
import 'interface/pages/personal_stock/personal_stock_page.dart';
import 'interface/pages/points_of_sale/points_of_sale_page.dart';
import 'interface/pages/reports/reports_page.dart';
import 'interface/pages/routes/routes_page.dart';
import 'interface/pages/splash/splash_page.dart';
import 'interface/pages/telemetry_boards/telemetry_boards_page.dart';
import 'interface/pages/telemetry_logs/telemetry_logs_page.dart';

class Router {
  static final _routes = {
    '/': () => SplashPage(),
    HomePage.route: () => HomePage(),
    LoginPage.route: () => LoginPage(),
    EditProfilePage.route: () => EditProfilePage(),
    GroupsPage.route: () => GroupsPage(),
    EditGroupPage.route: () => EditGroupPage(),
    PointsOfSalePage.route: () => PointsOfSalePage(),
    EditPointOfSalePage.route: () => EditPointOfSalePage(),
    CategoriesPage.route: () => CategoriesPage(),
    EditCategoryPage.route: () => EditCategoryPage(),
    MachinesPage.route: () => MachinesPage(),
    EditMachinePage.route: () => EditMachinePage(),
    GroupStockPage.route: () => GroupStockPage(),
    PersonalStockPage.route: () => PersonalStockPage(),
    RoutesPage.route: () => RoutesPage(),
    EditRoutePage.route: () => EditRoutePage(),
    CounterTypesPage.route: () => CounterTypesPage(),
    EditCounterTypePage.route: () => EditCounterTypePage(),
    ManagersPage.route: () => ManagersPage(),
    EditManagerPage.route: () => EditManagerPage(),
    OperatorsPage.route: () => OperatorsPage(),
    EditOperatorPage.route: () => EditOperatorPage(),
    TelemetryBoardsPage.route: () => TelemetryBoardsPage(),
    DetailedPointOfSalePage.route: () => DetailedPointOfSalePage(),
    CollectionsPage.route: () => CollectionsPage(),
    EditCollectionPage.route: () => EditCollectionPage(),
    DetailedMachinePage.route: () => DetailedMachinePage(),
    DetailedCollectionPage.route: () => DetailedCollectionPage(),
    FullPhotoPage.route: () => FullPhotoPage(),
    DetailedRoutePage.route: () => DetailedRoutePage(),
    DetailedGroupPage.route: () => DetailedGroupPage(),
    ReportsPage.route: () => ReportsPage(),
    TelemetryLogsPage.route: () => TelemetryLogsPage(),
    MachineLogsPage.route: () => MachineLogsPage(),
    DetailedOperatorPage.route: () => DetailedOperatorPage(),
  };

  static Route generateRoute(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (context) {
        if (_routes[settings.name] != null) {
          return _routes[settings.name]();
        }
        return Container();
      },
      settings: settings,
    );
  }
}
