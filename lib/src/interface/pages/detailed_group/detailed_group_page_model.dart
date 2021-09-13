import 'package:fl_chart/fl_chart.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/providers/groups_provider.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/core/services/interface_service.dart';

import '../../../locator.dart';

class DetailedGroupPageModel extends BaseViewModel {
  double currentPadding = 0;
  final interfaceService = locator<InterfaceService>();
  final userProvider = locator<UserProvider>();
  String period = 'DAILY';
  String groupId;
  final groupsProvider = locator<GroupsProvider>();

  void initData() async {
    setBusy(true);
    interfaceService.showLoader();
    await groupsProvider.getDetailedGroup(groupId, period);
    interfaceService.closeLoader();
    setBusy(false);
  }

  void getDetailedGroup(String p, double padding) async {
    if (p != period) {
      period = p;
      currentPadding = padding;
      notifyListeners();
      interfaceService.showLoader();
      await groupsProvider.getDetailedGroup(groupId, p);
      interfaceService.closeLoader();
    }
  }

  Map<String, dynamic> getChartData() {
    var maxY = 0.0;
    var xArray = [];
    groupsProvider.detailedGroup.barChartData.forEach((element) {
      if (element.income + element.prizeCount > maxY) {
        maxY = element.income + element.prizeCount;
      }
      xArray.add(element.date);
    });
    var incomeSpots = List<FlSpot>.generate(
      groupsProvider.detailedGroup.barChartData.length,
      (index) => FlSpot(
        index.toDouble(),
        groupsProvider.detailedGroup.barChartData[index].income,
      ),
    );

    var prizesSpots = List<FlSpot>.generate(
      groupsProvider.detailedGroup.barChartData.length,
      (index) => FlSpot(
        index.toDouble(),
        groupsProvider.detailedGroup.barChartData[index].prizeCount.toDouble(),
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
}
