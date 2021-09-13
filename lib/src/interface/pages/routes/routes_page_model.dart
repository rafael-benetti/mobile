import 'package:stacked/stacked.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/points_of_sale_provider.dart';
import '../../../core/providers/routes_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';

import '../../../locator.dart';

class RoutesPageModel extends BaseViewModel {
  final interfaceService = locator<InterfaceService>();
  final groupsProvider = locator<GroupsProvider>();
  final pointsOfSaleProvider = locator<PointsOfSaleProvider>();
  final colors = locator<AppColors>();
  final routesProvider = locator<RoutesProvider>();
  final userProvider = locator<UserProvider>();
  int offset = 0;
  String groupId;
  String label;
  String pointOfSaleId;
  String operatorId;

  List<String> filteredGroupsIds = [];

  void addToFilteredGroupsIds(String id) {
    filteredGroupsIds.add(id);
    notifyListeners();
  }

  void removeFromFilteredGroupsIds(String id) {
    filteredGroupsIds.removeWhere((element) => element == id);
    notifyListeners();
  }

  void clearFilteredGroupIds() {
    filteredGroupsIds = [];
    notifyListeners();
  }

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await groupsProvider.getAllGroups();
    await userProvider.getAllOperators();
    await pointsOfSaleProvider.getAllPointsOfSale();
    await routesProvider.getRoutes(
        offset: offset, shouldClearCurrentList: true);
    interfaceService.closeLoader();
    setBusy(false);
  }

  void filterRoutes(bool shouldClearCurrentList) async {
    await routesProvider.getRoutes(
      shouldClearCurrentList: shouldClearCurrentList,
      offset: offset,
      groupId: groupId,
      operatorId: operatorId,
      label: label,
      pointOfSaleId: pointOfSaleId,
    );
  }
}
