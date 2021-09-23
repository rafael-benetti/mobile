import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';

import '../../../core/providers/groups_provider.dart';
import '../../../locator.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../shared/validators.dart';
import '../../widgets/current_path.dart';
import '../../widgets/data_per_period.dart';
import '../../widgets/icon_translator.dart';
import '../../widgets/machines_sorted_by_last_collection.dart';
import '../../widgets/machines_sorted_by_last_connection.dart';
import '../../widgets/machines_sorted_by_stock.dart';
import '../../widgets/machines_statuses.dart';
import '../../widgets/period_selector.dart';
import '../edit_group/edit_group_page.dart';
import 'detailed_group_page_model.dart';
import 'widgets.dart';

class DetailedGroupPage extends StatelessWidget {
  static const route = '/detailedGroup';
  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DetailedGroupPageModel>.reactive(
      viewModelBuilder: () => DetailedGroupPageModel(),
      onModelReady: (model) {
        model.groupId = ModalRoute.of(context).settings.arguments;
        model.initData();
      },
      builder: (context, model, child) => Consumer<GroupsProvider>(
        builder: (context, groupsProvider, _) => Scaffold(
          body: model.isBusy
              ? Center()
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      iconTheme: IconThemeData(color: colors.iconsColor),
                      elevation: 0,
                      centerTitle: true,
                      floating: true,
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(15),
                      sliver: MultiSliver(
                        children: [
                          CurrentPath(
                            bottomMiddleTexts: [' / Parcerias'],
                            bottomFinalText:
                                ' / ${groupsProvider.detailedGroup.group.label ?? 'Parceria pessoal'}',
                            buttonText: 'Editar nome',
                            topText: 'Visão geral',
                            onPressed: () {
                              if (!groupsProvider
                                      .detailedGroup.group.isPersonal &&
                                  model.userProvider.user.permissions
                                      .editGroups) {
                                interfaceService.navigateTo(EditGroupPage.route,
                                    arguments:
                                        groupsProvider.detailedGroup.group);
                              } else {
                                interfaceService.showSnackBar(
                                    message:
                                        'Você não pode editar o nome da parceria pessoal',
                                    backgroundColor: colors.red);
                              }
                            },
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OPERACIONAL',
                                  style: styles.medium(fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Data da última compra de prêmios',
                                  style: styles.medium(fontSize: 14),
                                ),
                                SizedBox(height: 5),
                                Text(groupsProvider
                                            .detailedGroup.lastPurchaseDate !=
                                        null
                                    ? getFormattedDate(groupsProvider
                                        .detailedGroup.lastPurchaseDate)
                                    : '-'),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                          MachinesStatuses(
                            machinesNeverConnected: groupsProvider
                                .detailedGroup.machinesNeverConnected,
                            machinesWithoutTelemetryBoard: groupsProvider
                                .detailedGroup.machinesWithoutTelemetryBoard,
                            offlineMachines:
                                groupsProvider.detailedGroup.offlineMachines,
                            onlineMachines:
                                groupsProvider.detailedGroup.onlineMachines,
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                SizedBox(height: 25),
                                MachinesSortedByLastConnection(
                                  machinesSortedByLastConnection: groupsProvider
                                      .detailedGroup
                                      .machinesSortedByLastConnection,
                                ),
                                SizedBox(height: 10),
                                MachinesSortedByLastCollection(
                                  machinesSortedByLastCollection: groupsProvider
                                      .detailedGroup
                                      .machinesSortedByLastCollection,
                                ),
                                SizedBox(height: 10),
                                MachinesSortedByStock(
                                  machinesSortedByStock: groupsProvider
                                      .detailedGroup.machinesSortedByStock,
                                )
                              ],
                            ),
                          ),
                          PeriodSelector(
                            onPeriodSelected: model.getDetailedGroup,
                            currentPadding: model.currentPadding,
                          ),
                          DataPerPeriod(
                            givenPrizesPerPeriod:
                                groupsProvider.detailedGroup.givenPrizesCount,
                            incomePerPeriod:
                                groupsProvider.detailedGroup.income,
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                DetailedGroupChart(setup: model.getChartData())
                              ],
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 15),
                                PointsOfSaleSortedByIncome(
                                  pointsOfSaleSortedByIncome: groupsProvider
                                      .detailedGroup.pointsOfSaleSortedByIncome,
                                ),
                                SizedBox(height: 15),
                                // Text(
                                //   'Tipos de pagamento',
                                //   style: styles.medium(fontSize: 14),
                                // ),
                                // DetailedGroupPieChart(
                                //   incomeMethodDistributions: groupsProvider
                                //       .detailedGroup.incomeMethodDistributions,
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
