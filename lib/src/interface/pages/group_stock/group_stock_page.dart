import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/interface/pages/detailed_machine/detailed_machine_page.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';
import '../../shared/enums.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/machine_card.dart';
import '../../widgets/stock_card.dart';
import '../../widgets/stock_switcher.dart';
import '../../widgets/transfer.dart';
import '../../../locator.dart';

import 'group_stock_page_model.dart';

class GroupStockPage extends StatelessWidget {
  static const route = '/groupStock';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GroupStockPageModel>.reactive(
      viewModelBuilder: () => GroupStockPageModel(),
      onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Scaffold(
        body: Consumer<GroupsProvider>(
          builder: (context, _groupsProvider, _) {
            return model.isBusy
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
                        sliver: MultiSliver(children: [
                          CurrentPath(
                            topText: 'Estoque da parceria',
                            bottomFinalText: ' / Estoque da parceria',
                            buttonText: 'Criar produto',
                            onPressed: model.user.permissions.createProducts
                                ? () => model.popSelectItemToCreateDialog()
                                : null,
                          ),
                          if (_groupsProvider.groups.length > 1)
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Parceria',
                                    style: styles.light(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  CustomDropdownButton(
                                    initialValue:
                                        DropdownInputOption(title: 'Todas'),
                                    maxHeight: 157.5,
                                    onSelect: (option) {
                                      if (option.title.toLowerCase() ==
                                          'todas') {
                                        model.filterStock();
                                      } else {
                                        model.filterStock(_groupsProvider.groups
                                            .firstWhere((element) =>
                                                element.label == option.title)
                                            .id);
                                      }
                                    },
                                    values: [
                                          DropdownInputOption(title: 'Todas')
                                        ] +
                                        List.generate(
                                          model.groupsProvider.groups.length,
                                          (index) => DropdownInputOption(
                                              title: model.groupsProvider
                                                  .groups[index].label),
                                        ),
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ),
                          if (_groupsProvider.machinesInStock.isEmpty &&
                              _groupsProvider.prizes.isEmpty &&
                              _groupsProvider.supplies.isEmpty)
                            Text(
                              'Não há nada cadastrado no estoque.',
                              textAlign: TextAlign.center,
                            )
                          else
                            StockSwitcher(
                              numberOfMachines:
                                  _groupsProvider.machinesInStock.length,
                              numberOfPrizes: _groupsProvider.prizes.length,
                              numberOfSupplies: _groupsProvider.supplies.length,
                              currentlyShowing: model.currentlyShowing,
                              setCurrentlyShowing: model.toggleCurrentlyShowing,
                            ),
                          if (model.currentlyShowing == CurrentlyShowing.PRIZES)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                List.generate(
                                  _groupsProvider.prizes.length,
                                  (index) => Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          riseItemModalBottomSheet(
                                            item: _groupsProvider.prizes[index],
                                            context: context,
                                            popAddToStockDialog:
                                                model.popAddToStockDialog,
                                            removeFromStockDialog:
                                                model.popRemoveFromStockDialog,
                                            popSelectRecipientDialog:
                                                model.popSelectReceiverDialog,
                                            type: 'PRIZE',
                                          );
                                        },
                                        child: StockItem(
                                          stockItem:
                                              _groupsProvider.prizes[index],
                                          groupLabel: _groupsProvider.groups
                                              .firstWhere((group) =>
                                                  group.id ==
                                                  _groupsProvider
                                                      .prizes[index].groupId)
                                              .label,
                                          numberOfGroups:
                                              _groupsProvider.groups.length,
                                        ),
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (model.currentlyShowing ==
                              CurrentlyShowing.MACHINES)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                List.generate(
                                  _groupsProvider.machinesInStock.length,
                                  (index) => Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (model
                                              .user.permissions.editMachines) {
                                            locator<InterfaceService>()
                                                .navigateTo(
                                              DetailedMachinePage.route,
                                              arguments: _groupsProvider
                                                  .machinesInStock[index].id,
                                            );
                                          }
                                        },
                                        child: MachineCard(
                                          machine: _groupsProvider
                                              .machinesInStock[index],
                                          stockPage: true,
                                          groups: _groupsProvider.groups,
                                          pointsOfSale: model
                                              .pointsOfSaleProvider
                                              .pointsOfSale,
                                          telemetryBoards: model
                                              .telemetryBoardsProvider
                                              .telemetries,
                                        ),
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (model.currentlyShowing ==
                              CurrentlyShowing.SUPPLIES)
                            SliverList(
                              delegate: SliverChildListDelegate(
                                List.generate(
                                  _groupsProvider.supplies.length,
                                  (index) => Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          riseItemModalBottomSheet(
                                              item: _groupsProvider
                                                  .supplies[index],
                                              context: context,
                                              popAddToStockDialog:
                                                  model.popAddToStockDialog,
                                              removeFromStockDialog: model
                                                  .popRemoveFromStockDialog,
                                              popSelectRecipientDialog:
                                                  model.popSelectReceiverDialog,
                                              type: 'SUPPLY');
                                        },
                                        child: StockItem(
                                          stockItem:
                                              _groupsProvider.supplies[index],
                                          groupLabel: _groupsProvider.groups
                                              .firstWhere((group) =>
                                                  group.id ==
                                                  _groupsProvider
                                                      .supplies[index].groupId)
                                              .label,
                                          numberOfGroups:
                                              _groupsProvider.groups.length,
                                        ),
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ]),
                      )
                    ],
                  );
          },
        ),
      ),
    );
  }
}
