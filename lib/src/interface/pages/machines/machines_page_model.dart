import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';
import '../../../../src/interface/widgets/icon_translator.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/machines_provider.dart';
import '../../../core/providers/points_of_sale_provider.dart';
import '../../../core/providers/routes_provider.dart';
import '../../../core/providers/telemetry_boards_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import 'widgets.dart';
import '../../shared/colors.dart';
import '../../../locator.dart';

class MachinesPageModel extends BaseViewModel {
  final groupsProvider = locator<GroupsProvider>();
  final pointsOfSaleProvider = locator<PointsOfSaleProvider>();
  final machinesProvider = locator<MachinesProvider>();
  final categoriesProvider = locator<CategoriesProvider>();
  final routesProvider = locator<RoutesProvider>();
  final userProvider = locator<UserProvider>();
  final telemetryBoardsProvider = locator<TelemetryBoardsProvider>();
  final colors = locator<AppColors>();
  final user = locator<UserProvider>().user;

  void loadData() async {
    setBusy(true);
    locator<InterfaceService>().showLoader();
    machinesProvider.filteredMachines = [];
    await machinesProvider.filterMachines(offset: filteredOffset);
    await groupsProvider.getAllGroups();
    await pointsOfSaleProvider.getAllPointsOfSale();
    pointsOfSaleProvider.filteredPointsOfSale =
        pointsOfSaleProvider.pointsOfSale;
    await categoriesProvider.getAllCategories();
    await telemetryBoardsProvider.getAllTelemetries();
    await routesProvider.getRoutes(shouldClearCurrentList: true);
    await userProvider.getAllOperators();
    locator<InterfaceService>().closeLoader();
    setBusy(false);
  }

  void clearAllFilters({List<String> exceptions}) {
    exceptions ??= [];
    if (!exceptions.contains('filteredSerialNumber')) {
      filteredSerialNumber = null;
    }
    if (!exceptions.contains('filteredGroupId')) {
      filteredGroupId = null;
    }
    if (!exceptions.contains('filteredPointOfSaleId')) {
      filteredPointOfSaleId = null;
    }
    if (!exceptions.contains('filteredCategoryId')) {
      filteredCategoryId = null;
    }
    if (!exceptions.contains('filteredRouteId')) {
      filteredRouteId = null;
    }
    if (!exceptions.contains('filteredTelemetryStatus')) {
      filteredTelemetryStatus = null;
    }
    filteredOffset = 0;
    notifyListeners();
  }

  List<String> telemetryStatuses = [
    'Online',
    'Offline',
    'Nunca conectada',
    'Sem telemetria'
  ];
  String filteredTelemetryStatus;
  void filterTelemetryStatus(String value) {
    filteredTelemetryStatus = value;
    notifyListeners();
  }

  String filteredSerialNumber;
  void filterSerialNumber(String value) {
    filteredSerialNumber = value;
    notifyListeners();
  }

  bool filteredIsActive;
  void fiterIsActive(bool value) {
    filteredIsActive = value;
    notifyListeners();
  }

  String filteredGroupId;
  void filterGroupId(String value) async {
    filteredGroupId = value;
    interfaceService.showLoader();
    await pointsOfSaleProvider.filterPointsOfSale(
        groupId: value, clearCurrentList: true, limitless: true);
    clearAllFilters(exceptions: ['filteredGroupId', 'filteredCategoryId']);
    if (value != null) {
      routesProvider.filteredRoutes = routesProvider.routes
          .where((element) => element.groupIds.contains(value))
          .toList();
    } else {
      routesProvider.filteredRoutes = routesProvider.routes;
    }
    interfaceService.goBack();
    popFilterDialog();
    interfaceService.closeLoader();
    notifyListeners();
  }

  String filteredOperatorId;
  void filterOperatorId(String value) {
    filteredOperatorId = value;
    notifyListeners();
  }

  String filteredPointOfSaleId;
  void filterPointOfSaleId(String value) {
    filteredPointOfSaleId = value;
    notifyListeners();
  }

  String filteredCategoryId;
  void filterCategoryId(String value) {
    filteredCategoryId = value;
    notifyListeners();
  }

  String filteredRouteId;
  void filterRouteId(String value) {
    filteredRouteId = value;
    notifyListeners();
  }

  int filteredOffset = 0;

  int getNumberOfAppliedFilters() {
    var tmp = 0;
    if (filteredIsActive != null) {
      tmp++;
    }
    if (filteredGroupId != null) {
      tmp++;
    }
    if (filteredPointOfSaleId != null) {
      tmp++;
    }
    if (filteredCategoryId != null) {
      tmp++;
    }
    if (filteredRouteId != null) {
      tmp++;
    }
    if (filteredOperatorId != null) {
      tmp++;
    }
    return tmp;
  }

  Future filterMachines(bool clearCurrentList) async {
    locator<InterfaceService>().showLoader();
    var response = await machinesProvider.filterMachines(
      clearCurrentList: clearCurrentList,
      serialNumber: filteredSerialNumber,
      telemetryStatus: filteredTelemetryStatus,
      isActive: filteredIsActive,
      groupId: filteredGroupId,
      pointOfSaleId: filteredPointOfSaleId,
      categoryId: filteredCategoryId,
      routeId: filteredRouteId,
      offset: filteredOffset,
      operatorId: filteredOperatorId,
    );
    if (response.status != Status.success) {
      locator<InterfaceService>().showSnackBar(
          message: 'Erro ao filtrar máquinas. Tente novamente.',
          backgroundColor: colors.red);
    }
    locator<InterfaceService>().closeLoader();
  }

  void popFilterDialog() async {
    await locator<InterfaceService>().showModal(
      widget: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_down_outlined),
            color: colors.primaryColor,
            onPressed: () {
              interfaceService.goBack();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (groupsProvider.groups.length > 1)
                  FilterDropdown(
                    title: 'Parceria',
                    filteredField: filteredGroupId,
                    filterField: filterGroupId,
                    listOfOptions: groupsProvider.groups,
                  ),
                SizedBox(height: 10),
                FilterDropdown(
                  title: 'Categoria',
                  filteredField: filteredCategoryId,
                  filterField: filterCategoryId,
                  listOfOptions: categoriesProvider.categories,
                ),
                SizedBox(height: 10),
                FilterDropdown(
                  title: 'Rota',
                  filteredField: filteredRouteId,
                  filterField: filterRouteId,
                  listOfOptions: routesProvider.filteredRoutes,
                ),
                SizedBox(height: 10),
                FilterDropdown(
                  title: 'Localização',
                  filteredField: filteredPointOfSaleId,
                  filterField: filterPointOfSaleId,
                  listOfOptions: pointsOfSaleProvider.filteredPointsOfSale,
                ),
                SizedBox(height: 10),
                FilterDropdown(
                  title: 'Operador',
                  filteredField: filteredOperatorId,
                  filterField: filterOperatorId,
                  listOfOptions: userProvider.operators,
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status'),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 600,
                      child: CustomDropdownButton(
                        initialValue: DropdownInputOption(
                            title: filteredTelemetryStatus != null
                                ? telemetryStatuses.firstWhere((element) =>
                                    element == filteredTelemetryStatus)
                                : 'Todos'),
                        maxHeight: 112.5,
                        onSelect: (option) {
                          if (option.title == 'Todos') {
                            filteredTelemetryStatus = null;
                          } else {
                            filteredTelemetryStatus = option.title;
                          }
                        },
                        values: [DropdownInputOption(title: 'Todos')] +
                            List.generate(
                              telemetryStatuses.length,
                              (index) => DropdownInputOption(
                                title: telemetryStatuses[index],
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        interfaceService.showLoader();
                        clearAllFilters();
                        await pointsOfSaleProvider.filterPointsOfSale(
                            clearCurrentList: true);
                        interfaceService.goBack();
                        popFilterDialog();
                        interfaceService.closeLoader();
                      },
                      style: TextButton.styleFrom(
                        primary: colors.primaryColor,
                      ),
                      child: Text('Limpar filtros'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        filteredOffset = 0;
                        await filterMachines(true);
                        locator<InterfaceService>().goBack();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: colors.primaryColor,
                      ),
                      child: Text('Filtrar'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
