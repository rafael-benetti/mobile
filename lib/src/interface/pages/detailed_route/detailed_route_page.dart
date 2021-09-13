import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/core/providers/routes_provider.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/detailed_route/widgets.dart';
import '../../../../src/interface/pages/edit_route/edit_route_page.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/widgets/current_path.dart';
import '../../../../src/interface/widgets/data_per_period.dart';
import '../../../../src/interface/widgets/period_selector.dart';

import '../../../locator.dart';
import 'detailed_route_page_model.dart';

class DetailedRoutePage extends StatelessWidget {
  static const route = '/detailedRoute';
  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DetailedRoutePageModel>.reactive(
      viewModelBuilder: () => DetailedRoutePageModel(),
      onModelReady: (model) {
        model.routeId = ModalRoute.of(context).settings.arguments;
        model.loadData();
      },
      builder: (context, model, child) => Scaffold(
        body: Consumer<RoutesProvider>(builder: (context, routesProvider, _) {
          return Scaffold(
            body: model.isBusy
                ? Center()
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        iconTheme: IconThemeData(color: colors.primaryColor),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                        sliver: MultiSliver(
                          children: [
                            CurrentPath(
                              topText: routesProvider.detailedRoute.route.label,
                              bottomMiddleTexts: [' / Rota'],
                              bottomFinalText: ' / Visão geral',
                              buttonText: 'Editar',
                              onPressed: locator<UserProvider>()
                                      .user
                                      .permissions
                                      .editRoutes
                                  ? () {
                                      model.currentPadding = 0;
                                      model.getDetailedRoute(
                                          'DAILY', model.currentPadding);
                                      model.notifyListeners();
                                      locator<InterfaceService>().navigateTo(
                                          EditRoutePage.route,
                                          arguments: routesProvider
                                              .detailedRoute.route);
                                    }
                                  : null,
                            ),
                            Operational(
                              operatorName:
                                  routesProvider.detailedRoute.operatorName,
                            ),
                            PointsOfSale(
                              pointsOfSale:
                                  routesProvider.detailedRoute.pointsOfSale,
                            ),
                            Machines(
                              machines: routesProvider.detailedRoute.machines,
                            ),
                            if (locator<UserProvider>().user.role !=
                                Role.OPERATOR)
                              MultiSliver(
                                children: [
                                  PeriodSelector(
                                    onPeriodSelected: model.getDetailedRoute,
                                    currentPadding: model.currentPadding,
                                  ),
                                  SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Resultado da rota',
                                          style: styles.medium(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataPerPeriod(
                                    givenPrizesPerPeriod: routesProvider
                                        .detailedRoute.givenPrizesCount,
                                    incomePerPeriod:
                                        routesProvider.detailedRoute.income,
                                  ),
                                  SliverToBoxAdapter(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 20),
                                        DetailedRouteChart(
                                          setup: model.getChartData(),
                                        )
                                      ],
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Resultado por ponto de venda',
                                          style: styles.medium(fontSize: 15),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                  DetailedRoutePieChart(
                                    pieChartData: routesProvider
                                        .detailedRoute.pieChartData,
                                  ),
                                ],
                              ),
                            if (locator<UserProvider>()
                                .user
                                .permissions
                                .deleteRoutes)
                              SliverToBoxAdapter(
                                child: Container(
                                  padding: EdgeInsets.only(top: 20),
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () {
                                      model.popDeleteRoute();
                                    },
                                    child: Text(
                                      'Deletar rota',
                                      style: styles.regular(
                                        color: colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                    ],
                  ),
          );
        }),
      ),
    );
  }
}
