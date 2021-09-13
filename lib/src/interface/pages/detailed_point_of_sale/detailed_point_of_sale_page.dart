import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/core/providers/points_of_sale_provider.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/interface/widgets/data_per_period.dart';
import '../../../../src/interface/widgets/period_selector.dart';
import '../../../core/services/interface_service.dart';
import '../edit_point_of_sale/edit_point_of_sale_page.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';

import '../../../locator.dart';
import 'detailed_point_of_sale_page_model.dart';
import 'widgets.dart';

class DetailedPointOfSalePage extends StatelessWidget {
  static const route = '/detailedPointOfSale';

  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DetailedPointOfSalePageModel>.reactive(
      viewModelBuilder: () => DetailedPointOfSalePageModel(),
      onModelReady: (model) {
        model.pointOfSaleId = ModalRoute.of(context).settings.arguments;
        model.loadData();
      },
      builder: (context, model, child) => Consumer<PointsOfSaleProvider>(
        builder: (context, pointsOfSaleProvider, _) {
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
                              topText: pointsOfSaleProvider
                                  .detailedPointOfSale.pointOfSale.label,
                              bottomMiddleTexts: [' / Pontos de venda'],
                              bottomFinalText: ' / Visão geral',
                              buttonText: 'Editar',
                              onPressed: locator<UserProvider>()
                                      .user
                                      .permissions
                                      .editPointsOfSale
                                  ? () {
                                      locator<InterfaceService>().navigateTo(
                                          EditPointOfSalePage.route,
                                          arguments: pointsOfSaleProvider
                                              .detailedPointOfSale.pointOfSale);
                                    }
                                  : null,
                            ),
                            Operational(
                              groupLabel: pointsOfSaleProvider
                                      .detailedPointOfSale.groupLabel ??
                                  'Parceria pessoal',
                              pointOfSale: pointsOfSaleProvider
                                  .detailedPointOfSale.pointOfSale,
                            ),
                            BelongsToRoute(
                              onAddToRoute: model.onAddToRoute,
                              removeFromRoute:
                                  model.popRemovePointOfSaleFromRouteDialog,
                              route: pointsOfSaleProvider
                                  .detailedPointOfSale.route,
                            ),
                            Machines(
                              machinesInfo: pointsOfSaleProvider
                                  .detailedPointOfSale.machinesInfo,
                              onAddMachine: model.onAddMachine,
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(7.5, 7.5, 0, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Valor total no PdV: ',
                                      style: styles.medium(),
                                    ),
                                    Text(
                                      'R\$ ${model.totalCurrentMoney.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: styles.regular(
                                          color: colors.lightGreen),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (locator<UserProvider>().user.role !=
                                Role.OPERATOR)
                              MultiSliver(
                                children: [
                                  PeriodSelector(
                                    onPeriodSelected:
                                        model.getDetailedPointOfSale,
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
                                          'Resultado do ponto de venda',
                                          style: styles.medium(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataPerPeriod(
                                    givenPrizesPerPeriod: model
                                        .pointsOfSaleProvider
                                        .detailedPointOfSale
                                        .givenPrizesCount,
                                    incomePerPeriod: model.pointsOfSaleProvider
                                        .detailedPointOfSale.income,
                                  ),
                                  SliverToBoxAdapter(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 20),
                                        DetailedPointOfSaleChart(
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
                                          'Resultado por máquina',
                                          style: styles.medium(fontSize: 15),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                  DetailedPointOfSalePieChart(
                                    machinesInfo: pointsOfSaleProvider
                                        .detailedPointOfSale.machinesInfo,
                                  )
                                ],
                              )
                          ],
                        ),
                      )
                    ],
                  ),
          );
        },
      ),
    );
  }
}
