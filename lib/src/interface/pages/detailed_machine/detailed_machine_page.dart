import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/core/providers/machines_provider.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/detailed_machine/detailed_machine_page_model.dart';
import '../../../../src/interface/pages/detailed_machine/widgets.dart';
import '../../../../src/interface/pages/edit_collection/edit_collection_page.dart';
import '../../../../src/interface/pages/edit_machine/edit_machine_page.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../../src/interface/widgets/current_path.dart';
import '../../../../src/interface/widgets/data_per_period.dart';
import '../../../../src/interface/widgets/dialog_action.dart';
import '../../../../src/interface/widgets/period_selector.dart';

import '../../../locator.dart';

class DetailedMachinePage extends StatelessWidget {
  static const route = '/detailedMachine';

  final colors = locator<AppColors>();
  final styles = locator<TextStyles>();
  final refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DetailedMachinePageModel>.reactive(
        viewModelBuilder: () => DetailedMachinePageModel(),
        onModelReady: (model) {
          model.machineId = ModalRoute.of(context).settings.arguments;
          model.loadData();
        },
        builder: (context, model, child) =>
            Consumer<MachinesProvider>(builder: (context, machinesProvider, _) {
              void onRefresh() async {
                await model.refreshDetailedMachineData();
                refreshController.refreshCompleted();
              }

              return Scaffold(
                body: model.isBusy
                    ? Center()
                    : SmartRefresher(
                        header:
                            MaterialClassicHeader(color: colors.primaryColor),
                        controller: refreshController,
                        onRefresh: onRefresh,
                        child: CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                ),
                              ),
                              elevation: 0,
                              pinned: model.machinesProvider.detailedMachine
                                  .machine.maintenance,
                              centerTitle: true,
                              title: model.machinesProvider.detailedMachine
                                      .machine.maintenance
                                  ? Text(
                                      'Modo manutenção',
                                      style: styles.light(
                                          fontSize: 18, color: Colors.white),
                                    )
                                  : null,
                              backgroundColor: model.machinesProvider
                                      .detailedMachine.machine.maintenance
                                  ? Colors.red.withOpacity(0.9)
                                  : Theme.of(context).scaffoldBackgroundColor,
                              iconTheme: IconThemeData(
                                color: model.machinesProvider.detailedMachine
                                        .machine.maintenance
                                    ? Colors.white
                                    : colors.primaryColor,
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                              sliver: MultiSliver(
                                children: [
                                  SizedBox(height: 15),
                                  CurrentPath(
                                    topText:
                                        '${machinesProvider.detailedMachine.machine.serialNumber}',
                                    buttonText: 'Editar',
                                    bottomMiddleTexts: [' / Máquinas'],
                                    bottomFinalText: ' / Visão geral',
                                    onPressed: model.userProvider.user
                                            .permissions.editMachines
                                        ? () {
                                            locator<InterfaceService>()
                                                .navigateTo(
                                                    EditMachinePage.route,
                                                    arguments: machinesProvider
                                                        .detailedMachine
                                                        .machine);
                                          }
                                        : null,
                                  ),
                                  TripleButtons(
                                    addRemoteCredit: model.userProvider.user
                                            .permissions.addRemoteCredit
                                        ? () => model.popRemoteCreditDialog()
                                        : null,
                                    createCollection: () async {
                                      var isOnline = machinesProvider
                                                  .detailedMachine
                                                  .machine
                                                  .telemetryBoardId ==
                                              null
                                          ? false
                                          : checkIfTelemetryIsOnline(
                                              machinesProvider.detailedMachine
                                                  .telemetryBoard);
                                      if (machinesProvider.detailedMachine
                                                  .machine.locationId !=
                                              null &&
                                          isOnline) {
                                        model.currentPadding = 0;
                                        model.notifyListeners();
                                        await locator<InterfaceService>()
                                            .navigateTo(
                                                EditCollectionPage.route,
                                                arguments: machinesProvider
                                                    .detailedMachine.machine);
                                      } else if (isOnline) {
                                        await locator<InterfaceService>()
                                            .showDialogMessage(
                                          title: 'Não é possível fazer coleta',
                                          message:
                                              'No momento, esta máquina está no estoque.',
                                          actions: [
                                            DialogAction(
                                              title: 'Ok',
                                              onPressed: () {
                                                locator<InterfaceService>()
                                                    .goBack();
                                              },
                                            )
                                          ],
                                        );
                                      } else {
                                        await locator<InterfaceService>()
                                            .showDialogMessage(
                                          title: 'Não é possível fazer coleta',
                                          message:
                                              'No momento, esta máquina está offline, nunca foi conectada ou não possui telemetria.',
                                          actions: [
                                            DialogAction(
                                              title: 'Ok',
                                              onPressed: () {
                                                locator<InterfaceService>()
                                                    .goBack();
                                              },
                                            )
                                          ],
                                        );
                                      }
                                    },
                                    moveMachine: model.userProvider.user
                                            .permissions.editMachines
                                        ? () {
                                            model.popMoveMachineDialog();
                                          }
                                        : null,
                                  ),
                                  General(
                                    lastCollection: machinesProvider
                                        .detailedMachine.lastCollection,
                                    lastConnection: machinesProvider
                                        .detailedMachine.lastConnection,
                                    isMaintenance: machinesProvider
                                        .detailedMachine.machine.maintenance,
                                    changeIsMaintenance:
                                        model.changeMaintenanceMode,
                                    telemetryBoard: machinesProvider
                                        .detailedMachine.telemetryBoard,
                                    collectedBy: machinesProvider
                                        .detailedMachine.collectedBy,
                                  ),
                                  Operational(
                                    editTypeOfPrizeDialog:
                                        model.editTypeOfPrizeDialog,
                                    editMinimumPrizeCountDialog:
                                        model.editMinimumPrizeCountDialog,
                                    detailedMachine:
                                        machinesProvider.detailedMachine,
                                    editIncomeGoal: model.editIncomeGoal,
                                  ),
                                  if (model.userProvider.user.role !=
                                      Role.OPERATOR)
                                    MultiSliver(
                                      children: [
                                        PeriodSelector(
                                          onPeriodSelected:
                                              model.getDetailedMachine,
                                          currentPadding: model.currentPadding,
                                        ),
                                        DataPerPeriod(
                                          givenPrizesPerPeriod: machinesProvider
                                              .detailedMachine.givenPrizes,
                                          incomePerPeriod: machinesProvider
                                              .detailedMachine.income,
                                        ),
                                        SliverToBoxAdapter(
                                          child: Column(
                                            children: [
                                              SizedBox(height: 20),
                                              DetailedMachineChart(
                                                setup: model.getChartData(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  DataPerBox(
                                    categoryLabel: machinesProvider
                                        .detailedMachine.machine.categoryLabel,
                                    fixMachineStock: model.fixMachineStock,
                                    initiateRecoverProcess:
                                        model.initiateRecoverProcess,
                                    boxesInfo: machinesProvider
                                        .detailedMachine.boxesInfo,
                                    role: model.userProvider.user.role,
                                    reloadBox: model.userProvider.user.role ==
                                            Role.MANAGER
                                        ? model.chooseSourceToReload
                                        : model.choosePrizeToReload,
                                  ),
                                  if (machinesProvider.detailedMachine
                                      .transactionHistory.isNotEmpty)
                                    TransactionHistory(
                                      transactionHistory: machinesProvider
                                          .detailedMachine.transactionHistory,
                                      machine: machinesProvider
                                          .detailedMachine.machine,
                                    ),
                                  if (machinesProvider
                                      .detailedMachine.eventHistory.isNotEmpty)
                                    EventHistory(
                                      machineLogs: machinesProvider
                                          .detailedMachine.eventHistory,
                                      machine: machinesProvider
                                          .detailedMachine.machine,
                                    ),
                                  if (model.userProvider.user.permissions
                                      .deleteMachines)
                                    SliverToBoxAdapter(
                                      child: Container(
                                        padding: EdgeInsets.only(top: 20),
                                        width: double.infinity,
                                        child: TextButton(
                                          onPressed: () {
                                            model.popDeleteMachine();
                                          },
                                          child: Text(
                                            'Deletar máquina',
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
                      ),
              );
            }));
  }
}
