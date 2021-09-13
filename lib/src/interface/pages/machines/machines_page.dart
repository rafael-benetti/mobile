import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/interface/pages/detailed_machine/detailed_machine_page.dart';
import '../../../../src/interface/widgets/icon_translator.dart';
import '../../../core/providers/machines_provider.dart';
import '../../../core/services/interface_service.dart';
import '../edit_machine/edit_machine_page.dart';
import 'machines_page_model.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/machine_card.dart';

import '../../../locator.dart';

class MachinesPage extends StatelessWidget {
  static const route = '/machines';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();
  @override
  Widget build(BuildContext context) {
    Timer _timer;
    return ViewModelBuilder<MachinesPageModel>.reactive(
      viewModelBuilder: () => MachinesPageModel(),
      onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Scaffold(body:
          Consumer<MachinesProvider>(builder: (context, _machinesProvider, _) {
        final _scrollController = ScrollController();
        _scrollController.addListener(() {
          if (_scrollController.position.extentAfter == 0 &&
              _machinesProvider.filteredMachines.length !=
                  _machinesProvider.count) {
            model.filteredOffset += 5;
            model.filterMachines(false);
          }
        });
        return model.isBusy
            ? Center()
            : Scrollbar(
                child: CustomScrollView(
                  controller: _scrollController,
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
                            topText: 'Máquinas',
                            bottomFinalText: ' / Máquinas',
                            buttonText: 'Nova Máquina',
                            onPressed: model.user.permissions.createMachines
                                ? () async {
                                    model.clearAllFilters();
                                    await _machinesProvider.filterMachines(
                                        offset: model.filteredOffset,
                                        clearCurrentList: true);
                                    await locator<InterfaceService>()
                                        .navigateTo(EditMachinePage.route);
                                  }
                                : null,
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'Pesquisar',
                                  style: styles.light(fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                CustomTextField(
                                    initialValue: '',
                                    onChanged: (value) async {
                                      if (_timer != null) {
                                        _timer.cancel();
                                      }
                                      if (value == '') {
                                        model.filteredSerialNumber = null;
                                      } else {
                                        model.filteredSerialNumber = value;
                                      }
                                      _timer =
                                          Timer(Duration(milliseconds: 500),
                                              () async {
                                        model.filteredOffset = 0;
                                        await model.filterMachines(true);
                                      });
                                    }),
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    model.popFilterDialog();
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Icon(
                                          Icons.filter_list,
                                          color: colors.primaryColor,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Filtros',
                                          style: styles.regular(
                                              color: colors.primaryColor),
                                        ),
                                        SizedBox(width: 3),
                                        if (model.getNumberOfAppliedFilters() !=
                                            0)
                                          Text(
                                            '(${model.getNumberOfAppliedFilters()})',
                                            style: styles.regular(
                                                color: colors.primaryColor),
                                          ),
                                      ]),
                                      Row(
                                        children: [
                                          IconTranslator(
                                            icon: Icons.warning_amber_rounded,
                                            iconColor: Colors.amber,
                                            onTap: popIconTranslatorDialog,
                                          ),
                                          IconTranslator(
                                            icon: Feather.wifi_off,
                                            iconColor: colors.red,
                                            onTap: popIconTranslatorDialog,
                                          ),
                                          IconTranslator(
                                            icon: Feather.wifi,
                                            iconColor: colors.lightGreen,
                                            onTap: popIconTranslatorDialog,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15)
                              ],
                            ),
                          ),
                          if (_machinesProvider.filteredMachines
                              .where((element) => element.isActive)
                              .toList()
                              .isNotEmpty)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Máquinas (${_machinesProvider.count}) - ',
                                            style: styles.light(fontSize: 16),
                                          ),
                                          Icon(Icons.info_outline_rounded,
                                              size: 15),
                                          SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              'Prêmios entregues desde a última coleta',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: styles.light(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                    ] +
                                    List.generate(
                                      _machinesProvider.filteredMachines
                                          .where((element) => element.isActive)
                                          .toList()
                                          .length,
                                      (index) => Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              locator<InterfaceService>()
                                                  .navigateTo(
                                                      DetailedMachinePage.route,
                                                      arguments:
                                                          _machinesProvider
                                                              .filteredMachines
                                                              .where((element) =>
                                                                  element
                                                                      .isActive)
                                                              .toList()[index]
                                                              .id);
                                            },
                                            child: MachineCard(
                                              machine: _machinesProvider
                                                  .filteredMachines
                                                  .where((element) =>
                                                      element.isActive)
                                                  .toList()[index],
                                              groups:
                                                  model.groupsProvider.groups,
                                              stockPage: false,
                                              pointsOfSale: model
                                                  .pointsOfSaleProvider
                                                  .pointsOfSale,
                                              telemetryBoards: model
                                                  .telemetryBoardsProvider
                                                  .telemetries,
                                            ),
                                          ),
                                          SizedBox(height: 15)
                                        ],
                                      ),
                                    ),
                              ),
                            )
                          else
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 15),
                                  Text(
                                    model.getNumberOfAppliedFilters() == 0
                                        ? 'Nenhuma máquina cadastrada.'
                                        : 'Nenhuma máquina encontrada.',
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    )
                  ],
                ),
              );
      })),
    );
  }
}
