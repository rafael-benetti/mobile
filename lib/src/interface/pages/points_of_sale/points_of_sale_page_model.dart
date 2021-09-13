import 'package:stacked/stacked.dart';
import '../../../../src/core/providers/routes_provider.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/points_of_sale_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';

import '../../../locator.dart';

class PointsOfSalePageModel extends BaseViewModel {
  final user = locator<UserProvider>().user;
  final userProvider = locator<UserProvider>();
  final groupsProvider = locator<GroupsProvider>();
  final interfaceService = locator<InterfaceService>();
  final pointsOfSaleProvider = locator<PointsOfSaleProvider>();
  final routesProvider = locator<RoutesProvider>();

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await groupsProvider.getAllGroups();
    await userProvider.getAllOperators();
    await routesProvider.getRoutes(shouldClearCurrentList: true);
    await pointsOfSaleProvider.filterPointsOfSale(
        offset: filteredOffset, clearCurrentList: true);
    await pointsOfSaleProvider.getAllPointsOfSale();
    interfaceService.closeLoader();
    setBusy(false);
  }

  void clearAllFilters() {
    groupId = null;
    label = null;
    routeId = null;
    operatorId = null;
    filteredOffset = 0;
  }

  void filterPointsOfSale(bool clear) async {
    interfaceService.showLoader();
    await pointsOfSaleProvider.filterPointsOfSale(
      groupId: groupId,
      label: label,
      offset: filteredOffset,
      clearCurrentList: clear,
      routeId: routeId,
      operatorId: operatorId,
    );
    interfaceService.closeLoader();
  }

  String groupId;
  String routeId;
  String operatorId;
  String label;
  int filteredOffset = 0;
}
