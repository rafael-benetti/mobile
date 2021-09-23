import 'package:black_telemetry/src/core/models/user.dart';
import 'package:black_telemetry/src/core/services/interface_service.dart';
import 'package:black_telemetry/src/interface/pages/detailed_operator/widgets.dart';
import 'package:black_telemetry/src/interface/pages/edit_operator/edit_operator_page.dart';
import 'package:black_telemetry/src/interface/shared/colors.dart';
import 'package:black_telemetry/src/interface/widgets/current_path.dart';
import 'package:flutter/material.dart';

import 'package:sliver_tools/sliver_tools.dart';
import 'package:stacked/stacked.dart';

import '../../../locator.dart';
import 'detailed_operator_page_model.dart';

class DetailedOperatorPage extends StatelessWidget {
  static const route = '/detailedOperator';

  final colors = locator<AppColors>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DetailedOperatorPageModel>.reactive(
      viewModelBuilder: () => DetailedOperatorPageModel(),
      onModelReady: (model) {
        model.user = ModalRoute.of(context).settings.arguments as User;
      },
      builder: (context, model, child) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              iconTheme: IconThemeData(color: colors.primaryColor),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
              sliver: MultiSliver(
                children: [
                  CurrentPath(
                    topText: model.user.name,
                    bottomFinalText: ' / Operadores',
                    buttonText: 'Editar operador',
                    onPressed:
                        model.userProvider.user.permissions.createOperators
                            ? () {
                                locator<InterfaceService>().navigateTo(
                                  EditOperatorPage.route,
                                  arguments: model.user,
                                );
                              }
                            : null,
                  ),
                  if (model.user.stock.prizes.length > 0) PrizeList(),
                  SizedBox(height: 15),
                  if (model.user.stock.supplies.length > 0) SupplyList(),
                  if (model.user.stock.prizes.length == 0 &&
                      model.user.stock.supplies.length == 0)
                    SliverToBoxAdapter(
                      child:
                          Text('Este operador não possui estoque no momento.'),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
