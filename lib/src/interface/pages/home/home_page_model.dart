import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/providers/categories_provider.dart';
import '../../../../src/core/providers/counter_types_provider.dart';
import '../../../../src/core/providers/dashboard_provider.dart';
import '../../../../src/core/providers/groups_provider.dart';
import '../../../../src/core/providers/points_of_sale_provider.dart';
import '../../../../src/core/providers/routes_provider.dart';
import '../../../../src/interface/widgets/dialog_action.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/interface/pages/home/widgets.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';
import '../../../core/services/interface_service.dart';

import 'package:package_info/package_info.dart';
import '../../../locator.dart';

class HomePageModel extends BaseViewModel {
  final dashboardProvider = locator<DashboardProvider>();
  final categoriesProvider = locator<CategoriesProvider>();
  final counterTypesProvider = locator<CounterTypesProvider>();
  final groupsProvider = locator<GroupsProvider>();
  final routesProvider = locator<RoutesProvider>();
  final pointsOfSaleProvider = locator<PointsOfSaleProvider>();
  String period = 'DAILY';
  String routeId;
  String groupId;
  String pointOfSaleId;
  double currentPadding = 0;
  final interfaceService = locator<InterfaceService>();
  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();
  final user = locator<UserProvider>().user;
  int offset = 0;
  PackageInfo packageInfo;

  void initData() async {
    setBusy(true);
    interfaceService.showLoader();

    packageInfo = await PackageInfo.fromPlatform();
    await dashboardProvider.fetchData(period, groupId, routeId, pointOfSaleId);
    await dashboardProvider.getNumberOfNotifications();
    await categoriesProvider.getAllCategories();
    await counterTypesProvider.getAllCounterTypes();
    await groupsProvider.getAllGroups();
    await routesProvider.getRoutes(shouldClearCurrentList: true);
    await pointsOfSaleProvider.getAllPointsOfSale();
    interfaceService.closeLoader();
    setBusy(false);
  }

  int numberOfAppliedFilters() {
    var tmp = 0;
    if (groupId != null) tmp++;
    if (routeId != null) tmp++;
    if (pointOfSaleId != null) tmp++;
    return tmp;
  }

  void fetchDashboardData(
    String p,
    double padding,
  ) async {
    period = p;
    currentPadding = padding;
    notifyListeners();
    interfaceService.showLoader();
    await dashboardProvider.fetchData(p, groupId, routeId, pointOfSaleId);
    interfaceService.closeLoader();
  }

  void popFilters() {
    interfaceService.showDialogWithWidgets(
        title: 'Filtros',
        color: colors.primaryColor,
        widget: Container(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parceria',
                style: styles.regular(fontSize: 16),
              ),
              SizedBox(height: 7.5),
              CustomDropdownButton(
                maxHeight: 157.5,
                onSelect: (value) {
                  if (value.title.toLowerCase() == 'todas') {
                    groupId = null;
                  } else {
                    groupId = groupsProvider.groups
                        .firstWhere((element) => element.label == value.title)
                        .id;
                  }
                },
                initialValue: DropdownInputOption(
                    title: groupId == null
                        ? 'Todas'
                        : groupsProvider.groups
                            .firstWhere((element) => element.id == groupId)
                            .label),
                values: [DropdownInputOption(title: 'Todas')] +
                    List.generate(
                      groupsProvider.groups.length,
                      (index) => DropdownInputOption(
                        title: groupsProvider.groups[index].label,
                      ),
                    ),
              ),
              SizedBox(height: 10),
              Text(
                'Rota',
                style: styles.regular(fontSize: 16),
              ),
              SizedBox(height: 7.5),
              CustomDropdownButton(
                maxHeight: 157.5,
                onSelect: (value) {
                  if (value.title.toLowerCase() == 'todas') {
                    routeId = null;
                  } else {
                    routeId = routesProvider.routes
                        .firstWhere((element) => element.label == value.title)
                        .id;
                  }
                },
                initialValue: DropdownInputOption(title: 'Todas'),
                values: [
                      DropdownInputOption(
                        title: routeId == null
                            ? 'Todas'
                            : routesProvider.routes
                                .firstWhere((element) => element.id == routeId)
                                .label,
                      ),
                    ] +
                    List.generate(
                      routesProvider.routes.length,
                      (index) => DropdownInputOption(
                        title: routesProvider.routes[index].label,
                      ),
                    ),
              ),
              SizedBox(height: 10),
              Text(
                'Ponto de venda',
                style: styles.regular(fontSize: 16),
              ),
              SizedBox(height: 7.5),
              CustomDropdownButton(
                maxHeight: 157.5,
                onSelect: (value) {
                  if (value.title.toLowerCase() == 'todos') {
                    pointOfSaleId = null;
                  } else {
                    pointOfSaleId = pointsOfSaleProvider.pointsOfSale
                        .firstWhere((element) => element.label == value.title)
                        .id;
                  }
                },
                initialValue: DropdownInputOption(
                  title: pointOfSaleId == null
                      ? 'Todos'
                      : pointsOfSaleProvider.pointsOfSale
                          .firstWhere((element) => element.id == pointOfSaleId)
                          .label,
                ),
                values: [DropdownInputOption(title: 'Todos')] +
                    List.generate(
                      pointsOfSaleProvider.pointsOfSale.length,
                      (index) => DropdownInputOption(
                        title: pointsOfSaleProvider.pointsOfSale[index].label,
                      ),
                    ),
              ),
            ],
          ),
        ),
        actions: [
          DialogAction(
            title: 'Limpar filtros',
            onPressed: () {
              groupId = null;
              routeId = null;
              pointOfSaleId = null;
              interfaceService.goBack();
              fetchDashboardData(
                period,
                currentPadding,
              );
            },
          ),
          DialogAction(
            title: 'Filtrar',
            onPressed: () {
              interfaceService.goBack();
              fetchDashboardData(
                period,
                currentPadding,
              );
            },
          ),
        ]);
  }

  Map<String, dynamic> getChartData() {
    var maxY = 0.0;
    var xArray = [];
    dashboardProvider.dashboard.barChartData.forEach((element) {
      if (element.income + element.prizeCount > maxY) {
        maxY = element.income + element.prizeCount;
      }
      xArray.add(element.date);
    });
    var incomeSpots = List<FlSpot>.generate(
      dashboardProvider.dashboard.barChartData.length,
      (index) => FlSpot(
        index.toDouble(),
        dashboardProvider.dashboard.barChartData[index].income,
      ),
    );

    var prizesSpots = List<FlSpot>.generate(
      dashboardProvider.dashboard.barChartData.length,
      (index) => FlSpot(
        index.toDouble(),
        dashboardProvider.dashboard.barChartData[index].prizeCount.toDouble(),
      ),
    );
    if (maxY == 0) maxY = 5;

    return {
      'xArray': xArray,
      'maxY': maxY,
      'period': period,
      'incomeSpots': incomeSpots,
      'prizesSpots': prizesSpots
    };
  }

  Future getNotifications() async {
    interfaceService.showLoader();
    await dashboardProvider.getNotifications(offset: offset);
    interfaceService.closeLoader();
  }

  Future refreshDashboard() async {
    await dashboardProvider.fetchData(period, groupId, routeId, pointOfSaleId);
  }

  void riseNotificationsPage() async {
    offset = 0;
    dashboardProvider.notifications = [];
    await getNotifications();
    await locator<InterfaceService>().showModal(
      widget: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Notificações (${dashboardProvider.notificationsCount})',
            style: styles.regular(color: Colors.black, fontSize: 16),
          ),
          leading: IconButton(
            onPressed: () async {
              await dashboardProvider.getNumberOfNotifications();
              locator<InterfaceService>().goBack();
            },
            icon: Icon(
              Icons.keyboard_arrow_down_outlined,
              color: Colors.black,
              size: 25,
            ),
          ),
        ),
        backgroundColor: colors.backgroundColor,
        body: NotificationList(
          getMoreNotifications: () {
            offset += 5;
            getNotifications();
          },
        ),
      ),
    );
  }
}
