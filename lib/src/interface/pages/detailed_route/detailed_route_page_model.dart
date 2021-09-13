import 'package:fl_chart/fl_chart.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/providers/routes_provider.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/widgets/dialog_action.dart';

import '../../../locator.dart';

class DetailedRoutePageModel extends BaseViewModel {
  double currentPadding;
  String routeId;
  final routesProvider = locator<RoutesProvider>();
  final interfaceService = locator<InterfaceService>();
  String period;

  void loadData() async {
    interfaceService.showLoader();
    setBusy(true);
    await routesProvider.getDetailedRoute(routeId, 'DAILY');
    period = 'DAILY';
    currentPadding = 0;
    setBusy(false);
    interfaceService.closeLoader();
  }

  void getDetailedRoute(String p, double padding) async {
    if (p != period) {
      period = p;
      currentPadding = padding;
      notifyListeners();
      interfaceService.showLoader();
      await routesProvider.getDetailedRoute(
          routesProvider.detailedRoute.route.id, p);
      interfaceService.closeLoader();
    }
  }

  void popDeleteRoute() {
    interfaceService.showDialogMessage(
      title: 'Atenção',
      message:
          'Ao deletar uma rota, todas as máquinas vinculadas à ela perderão o operador responsável. Caso deseja continuar, tenha em mente de verificar essas máquinas posteriormente.',
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Continuar',
          onPressed: () async {
            interfaceService.showLoader();
            var response = await routesProvider
                .deleteRoute(routesProvider.detailedRoute.route.id);
            interfaceService.closeLoader();
            if (response.status == Status.success) {
              routesProvider.removeAtId(routesProvider.detailedRoute.route.id);
              interfaceService.goBack();
              interfaceService.goBack();
              interfaceService.showSnackBar(
                  message: 'Rota removida com sucesso',
                  backgroundColor: locator<AppColors>().lightGreen);
            }
          },
        ),
      ],
    );
  }

  Map<String, dynamic> getChartData() {
    var maxY = 0.0;
    var xArray = [];
    routesProvider.detailedRoute.chartData.forEach((element) {
      if (element.income + element.prizeCount > maxY) {
        maxY = element.income + element.prizeCount;
      }
      xArray.add(element.date);
    });
    var incomeSpots = List<FlSpot>.generate(
      routesProvider.detailedRoute.chartData.length,
      (index) => FlSpot(
        index.toDouble(),
        routesProvider.detailedRoute.chartData[index].income,
      ),
    );

    var prizesSpots = List<FlSpot>.generate(
      routesProvider.detailedRoute.chartData.length,
      (index) => FlSpot(
        index.toDouble(),
        routesProvider.detailedRoute.chartData[index].prizeCount.toDouble(),
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
