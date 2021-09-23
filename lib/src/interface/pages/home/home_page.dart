import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/core/providers/dashboard_provider.dart';
import '../../../../src/interface/widgets/data_per_period.dart';
import '../../../../src/interface/widgets/machines_sorted_by_last_collection.dart';
import '../../../../src/interface/widgets/machines_sorted_by_last_connection.dart';
import '../../../../src/interface/widgets/machines_sorted_by_stock.dart';
import '../../../../src/interface/widgets/machines_statuses.dart';
import '../../../../src/interface/widgets/period_selector.dart';
import 'home_page_model.dart';
import 'widgets.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../../locator.dart';

class HomePage extends StatelessWidget {
  static const route = '/home';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();
  final refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomePageModel>.reactive(
      viewModelBuilder: () => HomePageModel(),
      onModelReady: (model) {
        model.initData();
        // SystemChannels.lifecycle.setMessageHandler((msg) {
        //   if (msg == AppLifecycleState.resumed.toString()) {
        //     model.initData();
        //   }
        //   return;
        // });
      },
      builder: (context, model, child) =>
          Consumer<DashboardProvider>(builder: (context, dashboardProvider, _) {
        void onRefresh() async {
          await model.refreshDashboard();
          refreshController.refreshCompleted();
        }

        return Scaffold(
          drawer: Drawer(
            child: model.isBusy
                ? Container()
                : AppDrawer(
                    versionNumber: model.packageInfo.version,
                  ),
          ),
          body: model.isBusy
              ? Center()
              : SmartRefresher(
                  header: MaterialClassicHeader(color: colors.primaryColor),
                  controller: refreshController,
                  onRefresh: onRefresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        iconTheme: IconThemeData(color: colors.iconsColor),
                        elevation: 0,
                        actions: [
                          Notifications(
                            unreadNotifications:
                                dashboardProvider.numberOfUnreadNotifications,
                            riseNotificationsPage: model.riseNotificationsPage,
                          )
                        ],
                        title: Image.asset(
                          'assets/logo2.png',
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                        centerTitle: true,
                        floating: true,
                      ),
                      SliverPadding(
                        padding: EdgeInsets.all(15),
                        sliver: MultiSliver(
                          children: [
                            DashboardInfo(
                              filters: model.popFilters,
                              numberOfAppliedFilters:
                                  model.numberOfAppliedFilters(),
                            ),
                            if (model.user.role != Role.OPERATOR)
                              MultiSliver(
                                children: [
                                  PeriodSelector(
                                    onPeriodSelected: model.fetchDashboardData,
                                    currentPadding: model.currentPadding,
                                  ),
                                  DataPerPeriod(
                                    givenPrizesPerPeriod: dashboardProvider
                                        .dashboard.givenPrizesCount,
                                    incomePerPeriod:
                                        dashboardProvider.dashboard.income,
                                  ),
                                  SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 20),
                                        DashboardChart(
                                          setup: model.getChartData(),
                                        ),
                                        SizedBox(height: 25),
                                        Text(
                                          'OPERACIONAL',
                                          style: styles.medium(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            SliverPadding(
                              padding: EdgeInsets.only(top: 15),
                            ),
                            MachinesStatuses(
                              machinesNeverConnected: dashboardProvider
                                  .dashboard.machinesNeverConnected,
                              machinesWithoutTelemetryBoard: dashboardProvider
                                  .dashboard.machinesWithoutTelemetryBoard,
                              offlineMachines:
                                  dashboardProvider.dashboard.offlineMachines,
                              onlineMachines:
                                  dashboardProvider.dashboard.onlineMachines,
                            ),
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  SizedBox(height: 25),
                                  MachinesSortedByLastConnection(
                                    machinesSortedByLastConnection:
                                        dashboardProvider.dashboard
                                            .machinesSortedByLastConnection,
                                  ),
                                  SizedBox(height: 10),
                                  MachinesSortedByLastCollection(
                                    machinesSortedByLastCollection:
                                        dashboardProvider.dashboard
                                            .machinesSortedByLastCollection,
                                  ),
                                  SizedBox(height: 10),
                                  MachinesSortedByStock(
                                    machinesSortedByStock: dashboardProvider
                                        .dashboard.machinesSortedByStock,
                                  )
                                ],
                              ),
                            ),
                            // if (model.user.role != Role.OPERATOR)
                            //   SliverToBoxAdapter(
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         SizedBox(height: 15),
                            //         Text(
                            //           'Tipos de pagamento',
                            //           style: styles.medium(fontSize: 14),
                            //         ),
                            //         SizedBox(height: 10),
                            //         DashboardPieChart(
                            //           incomeMethodDistributions:
                            //               dashboardProvider.dashboard
                            //                   .incomeMethodDistributions,
                            //         ),
                            //       ],
                            //     ),
                            //   )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      }),
    );
  }
}
