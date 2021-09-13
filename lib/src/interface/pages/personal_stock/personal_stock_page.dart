import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';
import '../../../core/providers/user_provider.dart';
import '../../shared/colors.dart';
import '../../shared/enums.dart';
import '../../shared/text_styles.dart';
import '../../widgets/current_path.dart';
import '../../widgets/stock_card.dart';
import '../../widgets/stock_switcher.dart';
import '../../widgets/transfer.dart';

import '../../../locator.dart';
import 'personal_stock_page_model.dart';

class PersonalStockPage extends StatelessWidget {
  static const route = '/personalStock';
  final styles = locator<TextStyles>();
  final colors = locator<AppColors>();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PersonalStockPageModel>.reactive(
        viewModelBuilder: () => PersonalStockPageModel(),
        onModelReady: (model) => model.loadData(),
        builder: (context, model, child) => Scaffold(
              body: Consumer<UserProvider>(
                builder: (context, _userProvider, _) => model.isBusy
                    ? Center()
                    : CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            iconTheme:
                                IconThemeData(color: colors.primaryColor),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                            sliver: MultiSliver(
                              children: [
                                CurrentPath(
                                  topText: 'Meu estoque pessoal',
                                  bottomFinalText: ' / Meu estoque pessoal',
                                ),
                                if (_userProvider.prizes.isEmpty &&
                                    _userProvider.supplies.isEmpty)
                                  Text('Não há nada no seu estoque pessoal.',
                                      textAlign: TextAlign.center)
                                else
                                  StockSwitcher(
                                    numberOfMachines: 0,
                                    numberOfPrizes: _userProvider.prizes.length,
                                    numberOfSupplies:
                                        _userProvider.supplies.length,
                                    currentlyShowing: model.currentlyShowing,
                                    setCurrentlyShowing:
                                        model.toggleCurrentlyShowing,
                                  ),
                                if (model.currentlyShowing ==
                                    CurrentlyShowing.PRIZES)
                                  SliverList(
                                    delegate: SliverChildListDelegate(
                                      List.generate(
                                        _userProvider.prizes.length,
                                        (index) => Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                riseItemModalBottomSheet(
                                                  item: _userProvider
                                                      .prizes[index],
                                                  context: context,
                                                  popAddToStockDialog: null,
                                                  removeFromStockDialog: null,
                                                  popSelectRecipientDialog: model
                                                      .popSelectReceiverDialog,
                                                  type: 'PRIZE',
                                                );
                                              },
                                              child: StockItem(
                                                stockItem:
                                                    _userProvider.prizes[index],
                                                groupLabel: '',
                                                numberOfGroups: 0,
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
                                        _userProvider.supplies.length,
                                        (index) => Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                riseItemModalBottomSheet(
                                                    item: _userProvider
                                                        .supplies[index],
                                                    context: context,
                                                    popAddToStockDialog: null,
                                                    removeFromStockDialog: null,
                                                    popSelectRecipientDialog: model
                                                        .popSelectReceiverDialog,
                                                    type: 'SUPPLY');
                                              },
                                              child: StockItem(
                                                stockItem: _userProvider
                                                    .supplies[index],
                                                groupLabel: '',
                                                numberOfGroups: 0,
                                              ),
                                            ),
                                            SizedBox(height: 10)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
              ),
            ));
  }
}
